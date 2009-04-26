class CreateIphotoLibrary < ActiveRecord::Migration
  def self.up
    create_table :iphoto_medias do |t|
      t.string :type
      t.string :caption
      t.string :comment
      t.string :GUID
      t.float :aspect
      t.integer :rating
      t.references :roll
      t.datetime :date
      t.datetime :mod_date
      t.datetime :meta_mod_date
      t.string :image_path
      t.string :thumb_path
      t.string :image_type

      t.timestamps
    end
    create_table :iphoto_rolls do |t|
      t.string :name
      t.datetime :date
      t.references :key_photo
      t.integer :photo_count
      t.text :key_list

      t.timestamps
    end
  end

  def self.down
    drop_table :iphoto_medias
    drop_table :iphoto_rolls
  end
end