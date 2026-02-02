class CreateClaims < ActiveRecord::Migration[7.1]
  def change
    create_table :claims do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.text :proof_note
      t.string :claim_code

      t.timestamps
    end
  end
end
