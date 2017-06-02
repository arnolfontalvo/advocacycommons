class CreateTaggings < ActiveRecord::Migration[5.0]
  def change
    create_table :taggings do |t|
      t.string :identifiers
      t.string :origin_system
      t.string :item_type
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
