class Media < ActiveRecord::Base
  set_table_name "iphoto_medias"
  
  include IphotoRecord
  set_plist_mapping 'Caption' => :caption, 'Comment' => :comment, 'Aspect Ratio' => :aspect, 'Rating' => :rating, 'Roll' => :roll_id, 'DateAsTimerInterval' => :date, 'ModDateAsTimerInterval' => :mod_date, 'MetaModDateAsTimerInterval' => :meta_mod_date, 'ImagePath' => :image_path, 'ThumbPath' => :thumb_path, 'ImageType' => :image_type, 'GUID' => :GUID
  set_plist_proc :date, IphotoRecord::DateProc
  set_plist_proc :mod_date, IphotoRecord::DateProc
  set_plist_proc :meta_mod_date, IphotoRecord::DateProc
  set_plist_proc :image_path, Proc.new { |p| p.sub(IphotoLibrary.path, '') }
  set_plist_proc :thumb_path, Proc.new { |p| p.sub(IphotoLibrary.path, '') }
  
  belongs_to :roll
  
  def thumb_path(append=true)
    if append
      IphotoLibrary.server + super
    else
      super
    end
  end
  
  def image_path(append=true)
    if append
      IphotoLibrary.server + super
    else
      super
    end
  end
end
