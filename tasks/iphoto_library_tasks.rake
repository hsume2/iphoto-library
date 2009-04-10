namespace :iphoto do  
  desc "Resets iPhoto data in database"
  task(:reset => :environment) do
    puts "Destroying #{Media.count} media entries"
    Media.delete_all
    puts "Destroying #{Roll.count} roll entries"
    Roll.delete_all
  end

  desc "Updates iPhoto data incrementally into database"
  task(:update => :environment) do
    @@library = IphotoLibrary.path
    albumdata = IphotoLibrary.albumdata_path

    result = Plist::parse_xml(albumdata)

    @rolls = result['List of Rolls']
    @list = result['Master Image List']

    @rolls.each do |roll|
      roll_model = Roll.find(roll['RollID'])
      if roll_model.nil?
        created = create_roll(roll)

        puts "Created #{created}"
      else
        update_roll(roll_model, roll)
      end
    end

    @list.each_pair do |key, value|
      media_model = Media.find(key)
      if media_model.nil?
        case value['MediaType']
        when 'Image'
          created = create_media('Photo', key, value)
        when 'Movie'
          created = create_media('Movie', key, value)
        end
        puts "Created #{created}"
      else
        update_media(media_model, value)
      end
    end
  end

  desc "Load iPhoto library AlbumData.xml into database"
  task(:load => :reset) do
    @@library = IphotoLibrary.path
    albumdata = IphotoLibrary.albumdata_path

    result = Plist::parse_xml(albumdata)

    @rolls = result['List of Rolls']
    @list = result['Master Image List']

    roll_count = 0
    @rolls.each do |roll|
      create_roll(roll)
      roll_count += 1
    end
    
    puts "Created #{roll_count} roll entries"

    media_count = 0
    @list.each_pair do |key, value|
      case value['MediaType']
      when 'Image'
        created = create_media('Photo', key, value)
      when 'Movie'
        created = create_media('Movie', key, value)
      end
      media_count += 1
    end
    
    puts "Created #{media_count} media entries"
  end

  private
  
  @@library = nil
  
  def create_roll(plist_roll)
    return Roll.create(roll_hash(plist_roll)) do |r|
      r.id = plist_roll['RollID']
    end
  end
  
  def roll_hash(plist_roll)
    {
      :name => plist_roll['RollName'],
      :date => Time.at(plist_roll['RollDateAsTimerInterval'].to_f + 978307200),
      :key_photo_id => plist_roll['KeyPhotoKey'],
      :photo_count => plist_roll['PhotoCount'],
      :key_list => plist_roll['KeyList']
    }
  end
  
  def update_roll(record, plist_roll)
    temp_hash = roll_hash(plist_roll)
    
    # Values undergo changes when the record is built so we can't just use the temp_hash
    current_roll = Roll.new(temp_hash)
    current_roll_attributes = current_roll.attributes
    
    # Rolls are created with roll_hash, so only keys in roll_hash will be checked
    # for modifications
    
    current_roll_attributes.delete_if { |key, value| !temp_hash.include?(key.to_sym) }
    
    # Loop variables
    record_attributes = record.attributes
    modified_attributes = Hash.new
    
    current_roll_attributes.each_pair do |key, value|
      unless record_attributes[key] == value # Checks for changes
        modified_attributes[key] = value # Stores changes
      end
    end
    
    # Updates if needed
    if !modified_attributes.blank? and record.update_attributes(modified_attributes)
      puts "Updated #{record} with #{modified_attributes.inspect}"
    end
  end

  def create_media(model, key, value)
    return_model = nil
    eval "return_model = #{model}.create(media_hash(value)) do |image|
      image.id = key
      image.GUID = value['GUID']
    end", binding
    return return_model
  end
  
  def media_hash(plist)
    {
      :caption => plist['Caption'],
      :comment => plist['Comment'],
      :aspect => plist['Aspect Ratio'],
      :rating => plist['Rating'],
      :roll_id => plist['Roll'],
      :date => Time.at(plist['DateAsTimerInterval'].to_f + 978307200),
      :mod_date => Time.at(plist['ModDateAsTimerInterval'].to_f + 978307200),
      :meta_mod_date => Time.at(plist['MetaModDateAsTimerInterval'].to_f + 978307200),
      :image_path => plist['ImagePath'].sub(@@library, ''),
      :thumb_path => plist['ThumbPath'].sub(@@library, ''),
      :image_type => plist['ImageType']
    }
  end
  
  def update_media(record, plist)
    temp_hash = media_hash(plist)

    # Values undergo changes when the record is built so we can't just use the temp_hash
    current_media = Media.new(temp_hash)
    current_media_attributes = current_media.attributes

    # Media are created with media_hash, so only keys in media_hash will be checked
    # for modifications

    current_media_attributes.delete_if { |key, value| !temp_hash.include?(key.to_sym) }

    # Loop variables
    record_attributes = record.attributes
    modified_attributes = Hash.new

    current_media_attributes.each_pair do |key, value|
      unless key == "meta_mod_date" or key == "aspect" # Currently ignore these two
        unless record_attributes[key] == value # Checks for changes
          modified_attributes[key] = value # Stores changes
        end
      end
    end
    
    # Updates if needed
    if !modified_attributes.blank? and record.update_attributes(modified_attributes)
       puts "Updated #{record} with #{modified_attributes.inspect}"
     end
  end
end