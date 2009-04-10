class Roll < ActiveRecord::Base
  set_table_name "iphoto_rolls"
  belongs_to :key_photo, :class_name => 'Media', :foreign_key => 'key_photo_id'
  has_many :medias, :class_name => 'Media', :foreign_key => 'roll_id'
  serialize :key_list
end
