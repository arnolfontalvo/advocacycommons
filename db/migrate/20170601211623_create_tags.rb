class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :identifiers
      t.string :origin_system
      t.string :description
      t.string :name
      t.integer :creator_id, index: true
      t.integer :modified_by_id, index: true
      t.timestamps
    end
  end
end
