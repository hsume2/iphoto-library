module Iphoto
  module Library
    def self.included(base) #:nodoc:
      base.extend(Iphoto::Library::ClassMethods)
    end

    module ClassMethods
      # Sets the associations and appropriate table.
      def acts_as_iphoto_library
        set_table_name "iphoto_libraries"

        has_many :rolls, :class_name => 'Iphoto::Roll'
        has_many :photos, :class_name => 'Iphoto::Photo'
        has_many :movies, :class_name => 'Iphoto::Movie'
        has_many :keywords, :class_name => 'Iphoto::Keyword'

        include Iphoto::Library::InstanceMethods
        extend Iphoto::Library::SingletonMethods
      end
    end

    module InstanceMethods
      # Loads everything from AlbumData.xml into the database
      # It's up to the implementer to decide how the +albumdata_path+ is generated.
      def migrate_albumdata(albumdata_path)
        Iphoto::Roll.delete_all
        Iphoto::Media.delete_all
        Iphoto::Keyword.delete_all

        result = Plist::parse_xml(albumdata_path)

        @rolls = result['List of Rolls']
        @list = result['Master Image List']
        @keywords = result['List of Keywords']

        roll_count = 0
        @rolls.each do |roll|
          roll_count += 1 if Roll.from_plist(roll['RollID'], roll, :library_id => self.id)
        end

        media_count = 0
        @list.each_pair do |key, media|
          case media['MediaType']
          when 'Image'
            media_count += 1 if Iphoto::Photo.from_plist(key, media)
          when 'Movie'
            media_count += 1 if Iphoto::Movie.from_plist(key, media)
          end
        end

        @keywords.each do |key, word_name|
          Iphoto::Keyword.create(:name => word_name, :library_id => self.id) do |k|
            k.id = key
          end
        end

        puts "Created #{roll_count} roll entries"
        puts "Created #{media_count} media entries"
      end
    end

    module SingletonMethods #:nodoc:

    end
  end
end
