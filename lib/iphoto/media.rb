module Iphoto
  class Media < ActiveRecord::Base
    set_table_name "iphoto_medias"

    include Iphoto::Record
    set_plist_mapping 'Caption' => :caption, 'Comment' => :comment, 'Aspect Ratio' => :aspect, 'Rating' => :rating, 'Roll' => :roll_id, 'DateAsTimerInterval' => :date, 'ModDateAsTimerInterval' => :mod_date, 'MetaModDateAsTimerInterval' => :meta_mod_date, 'ImagePath' => :image_path, 'ThumbPath' => :thumb_path, 'ImageType' => :image_type, 'GUID' => :GUID, 'Keywords' => :keywords
    set_plist_proc :date, Iphoto::Record::DateProc
    set_plist_proc :mod_date, Iphoto::Record::DateProc
    set_plist_proc :meta_mod_date, Iphoto::Record::DateProc
    # set_plist_proc :image_path, Proc.new { |p| p.sub(Iphoto::path, '') }
    # set_plist_proc :thumb_path, Proc.new { |p| p.sub(Iphoto::path, '') }

    belongs_to :roll
    serialize :keywords

    def thumb_path(append=true)
      # if append
      #   IphotoLibrary.server + super
      # else
        super
      # end
    end

    def image_path(append=true)
      # if append
      #   IphotoLibrary.server + super
      # else
        super
      # end
    end
  end
end
