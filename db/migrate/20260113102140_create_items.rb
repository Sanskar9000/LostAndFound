class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :title
      t.text :description
      t.string :item_type
      t.string :category
      t.string :location
      t.date :found_on
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
