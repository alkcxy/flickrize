class CreateWithGalleries < ActiveRecord::Migration
  def change
    create_table :with_galleries do |t|
      t.integer :gallery_id
      t.integer :photo_id

      t.timestamps
    end
  end
end
