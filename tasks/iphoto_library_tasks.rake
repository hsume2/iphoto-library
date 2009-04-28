namespace :iphoto do  
  desc "Resets iPhoto data in database"
  task(:reset => :environment) do
    puts "Destroying #{Media.count} media entries"
    Media.delete_all
    puts "Destroying #{Roll.count} roll entries"
    Roll.delete_all
    Keyword.delete_all
  end

  desc "Updates iPhoto data incrementally into database"
  task(:update => :environment) do
    albumdata = IphotoLibrary.albumdata_path

    result = Plist::parse_xml(albumdata)

    @rolls = result['List of Rolls']
    @list = result['Master Image List']
    @keywords = result['List of Keywords']
    Keyword.delete_all

    # First checks if any rolls or media have been deleted, pushes those changes
    existing_ids = Roll.find(:all, :select => 'id').map { |m| m.id }
    current_ids = @rolls.map { |r| r['RollID'] }
    nonexistent_ids = existing_ids - current_ids

    unless nonexistent_ids.empty?
      puts "Deleting rolls with ids: #{nonexistent_ids.inspect}"
      Roll.delete(nonexistent_ids)
    end

    existing_ids = Media.find(:all, :select => 'id').map { |m| m.id }
    current_ids = @list.map { |k, v| k.to_i }
    nonexistent_ids = existing_ids - current_ids

    unless nonexistent_ids.empty?
      puts "Deleting media with ids: #{nonexistent_ids.inspect}"
      Media.delete(nonexistent_ids)
    end
    
    # Next create new rolls or media / update existing ones

    updated_roll_count = 0
    @rolls.each do |roll|
      begin
        roll_model = Roll.find(roll['RollID'])
      rescue ActiveRecord::RecordNotFound
        created = Roll.from_plist(roll['RollID'], roll)
        puts "Created #{created}"
      else
        updated_roll_count += 1 if roll_model.update_from_plist(roll)
      end
    end
    
    update_media_count = 0
    @list.each_pair do |key, media|
      begin
        media_model = Media.find(key)
      rescue ActiveRecord::RecordNotFound
        if media_model.nil?
          case media['MediaType']
          when 'Image'
            created = Photo.from_plist(key, media)
          when 'Movie'
            created = Movie.from_plist(key, media)
          end
          puts "Created #{created}"
        end
      else
        update_media_count += 1 if media_model.update_from_plist(media)
      end
    end
    
    @keywords.each do |key, name|
      Keyword.create(:name => name) do |k|
        k.id = key
      end
    end
    
    puts "Updated #{updated_roll_count} roll entries"
    puts "Updated #{update_media_count} media entries"
  end

  desc "Load iPhoto library AlbumData.xml into database"
  task(:load => :reset) do
    albumdata = IphotoLibrary.albumdata_path

    result = Plist::parse_xml(albumdata)

    @rolls = result['List of Rolls']
    @list = result['Master Image List']
    @keywords = result['List of Keywords']
    
    roll_count = 0
    @rolls.each do |roll|
      roll_count += 1 if Roll.from_plist(roll['RollID'], roll)
    end

    media_count = 0
    @list.each_pair do |key, media|
      case media['MediaType']
      when 'Image'
        media_count += 1 if Photo.from_plist(key, media)
      when 'Movie'
        media_count += 1 if Movie.from_plist(key, media)
      end
    end
    
    @keywords.each do |key, name|
      Keyword.create(:name => name) do |k|
        k.id = key
      end
    end
    
    puts "Created #{roll_count} roll entries"
    puts "Created #{media_count} media entries"
  end
end
