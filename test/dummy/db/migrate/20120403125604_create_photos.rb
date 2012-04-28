class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :flickr_id
      t.string :title
      t.integer :set_id
      t.integer :gallery_id
      t.text :description
      t.integer :is_public
      t.integer :hidden
      t.integer :farm
      t.integer :server
      t.string :secret
      t.string :originalsecret
      t.string :originalformat

      t.timestamps
    end
  end
end
