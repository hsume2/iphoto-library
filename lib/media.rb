class Media < ActiveRecord::Base
  set_table_name "iphoto_medias"
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
