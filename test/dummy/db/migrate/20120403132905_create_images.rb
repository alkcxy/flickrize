class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :flickr_id
      t.string :title
      t.text :description
      t.integer :farm
      t.integer :server
      t.string :secret
      t.string :originalsecret
      t.string :originalformat

      t.timestamps
    end
  end
end
