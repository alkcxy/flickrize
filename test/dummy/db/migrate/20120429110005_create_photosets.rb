class CreatePhotosets < ActiveRecord::Migration
  def change
    create_table :photosets do |t|
      t.integer :set_id
      t.string :title
      t.text :description
      t.string :set_url

      t.timestamps
    end
  end
end
