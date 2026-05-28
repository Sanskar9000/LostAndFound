class CreateItemConversationsAndMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :item_conversations do |t|
      t.references :item, null: false, foreign_key: true
      t.references :participant_one, null: false, foreign_key: { to_table: :users }
      t.references :participant_two, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :item_conversations,
              [:item_id, :participant_one_id, :participant_two_id],
              unique: true,
              name: "index_item_conversations_on_item_and_participants"

    create_table :messages do |t|
      t.references :item_conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:item_conversation_id, :created_at]
    add_index :messages, [:item_conversation_id, :read_at]
  end
end
