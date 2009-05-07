module Iphoto
  class Roll < ActiveRecord::Base
    set_table_name "iphoto_rolls"

    include Iphoto::Record
    set_plist_mapping 'RollName' => :name, 'KeyPhotoKey' => :key_photo_id, 'PhotoCount' => :photo_count, 'KeyList' => :key_list, 'RollDateAsTimerInterval' => :date
    set_plist_proc :date, Iphoto::Record::DateProc

    belongs_to :key_photo, :class_name => 'Media', :foreign_key => 'key_photo_id'
    has_many :medias, :class_name => 'Media', :foreign_key => 'roll_id'
    serialize :key_list
  end
end
