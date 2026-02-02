class AddVerifiedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :verified, :boolean, default: true, null: false
  end
end
