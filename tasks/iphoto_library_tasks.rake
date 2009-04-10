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
    library = IphotoLibrary.path

    albumdata = IphotoLibrary.albumdata_path

    puts "Loading #{albumdata}"

    result = Plist::parse_xml(albumdata)

    @rolls = result['List of Rolls']
    @list = result['Master Image List']

    @rolls.each do |roll|
      unless Roll.exists?(roll['RollID'])
        created = create_roll(roll)

        puts "Created #{created}"
      end
    end

    @list.each_pair do |key, value|
      unless Media.exists?(key)
        case value['MediaType']
        when 'Image'
          created = create_media('Photo', key, value, library)
        when 'Movie'
          created = create_media('Movie', key, value, library)
        end
        puts "Created #{created}"
      end
    end
  end

  desc "Load iPhoto library AlbumData.xml into database"
  task(:load => :reset) do
    library = IphotoLibrary.path

    albumdata = IphotoLibrary.albumdata_path

    puts "Loading #{albumdata}"

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
        created = create_media('Photo', key, value, library)
      when 'Movie'
        created = create_media('Movie', key, value, library)
      end
      media_count += 1
    end
    
    puts "Created #{media_count} media entries"
  end

  private
  def create_roll(roll)
    return Roll.create(
    :name => roll['RollName'],
    :date => Time.at(roll['RollDateAsTimerInterval'].to_f + 978307200),
    :key_photo_id => roll['KeyPhotoKey'],
    :photo_count => roll['PhotoCount'],
    :key_list => roll['KeyList']
    ) do |r|
      r.id = roll['RollID']
    end
  end

  def create_media(model, key, value, library)
    return_model = nil
    eval "return_model = #{model}.create(
    :caption => value['Caption'],
    :comment => value['Comment'],
    :aspect => value['Aspect Ratio'],
    :rating => value['Rating'],
    :roll_id => value['Roll'],
    :date => Time.at(value['DateAsTimerInterval'].to_f + 978307200),
    :mod_date => Time.at(value['ModDateAsTimerInterval'].to_f + 978307200),
    :meta_mod_date => Time.at(value['MetaModDateAsTimerInterval'].to_f + 978307200),
    :image_path => value['ImagePath'].sub(library, ''),
    :thumb_path => value['ThumbPath'].sub(library, ''),
    :image_type => value['ImageType']
    ) do |image|
      image.id = key
      image.GUID = value['GUID']
    end", binding
    return return_model
  end
end