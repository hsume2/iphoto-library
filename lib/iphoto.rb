module Iphoto
  def self.included(base) #:nodoc:
    base.extend(Iphoto::ClassMethods)
  end
  
  module ClassMethods
    # To act as an iphoto library, the base class must include the methods for:
    # * <tt>albumdata_path</tt> the path of AlbumData.xml via the base class
    # * <tt>library_id</tt> that any Rolls, Photos, Movies, Keywords belong to via the base class
    #
    # Sets the associations
    def acts_as_iphoto_library
      Iphoto::Roll.instance_eval do
        belongs_to :library, :class_name => self.class_name
      end
      Iphoto::Media.instance_eval do
        belongs_to :library, :class_name => self.class_name
      end
      Iphoto::Keyword.instance_eval do
        belongs_to :library, :class_name => self.class_name
      end
      
      has_many :rolls, :class_name => 'Iphoto::Roll'
      has_many :photos, :class_name => 'Iphoto::Photo'
      has_many :movies, :class_name => 'Iphoto::Movie'
      has_many :keywords, :class_name => 'Iphoto::Keyword'
      
      include Iphoto::InstanceMethods
      extend Iphoto::SingletonMethods
    end
  end

  module InstanceMethods
    # Loads everything from AlbumData.xml into the database
    def migrate_albumdata
      Iphoto::Roll.delete_all
      Iphoto::Media.delete_all
      Iphoto::Keyword.delete_all
      
      result = Plist::parse_xml(albumdata_path)

      @rolls = result['List of Rolls']
      @list = result['Master Image List']
      @keywords = result['List of Keywords']
      
      roll_count = 0
      @rolls.each do |roll|
        roll_count += 1 if Roll.from_plist(roll['RollID'], roll, :library_id => library_id)
      end
      
      media_count = 0
      @list.each_pair do |key, media|
        case media['MediaType']
        when 'Image'
          media_count += 1 if Iphoto::Photo.from_plist(key, media, :library_id => library_id)
        when 'Movie'
          media_count += 1 if Iphoto::Movie.from_plist(key, media, :library_id => library_id)
        end
      end
      
      @keywords.each do |key, word_name|
        Iphoto::Keyword.create(:name => word_name, :library_id => library_id) do |k|
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