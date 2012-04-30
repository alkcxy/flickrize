class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.integer :photoset_id
      t.string :title
      t.text :description
      t.string :set_url

      t.timestamps
    end
  end
end
