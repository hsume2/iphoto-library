class Media < ActiveRecord::Base
  set_table_name "iphoto_medias"
  belongs_to :roll
  
  def thumb_path
    IphotoLibrary.server + super
  end
  
  def image_path
    IphotoLibrary.server + super
  end
end
