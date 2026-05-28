class CreateCampusesAndBackfillUsersAndItems < ActiveRecord::Migration[7.1]
  class MigrationCampus < ApplicationRecord
    self.table_name = "campuses"
  end

  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  class MigrationItem < ApplicationRecord
    self.table_name = "items"
  end

  def up
    create_table :campuses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :location
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :campuses, :code, unique: true
    add_index :campuses, :active

    add_reference :users, :campus, foreign_key: { to_table: :campuses }
    add_reference :items, :campus, foreign_key: { to_table: :campuses }

    MigrationCampus.reset_column_information
    MigrationUser.reset_column_information
    MigrationItem.reset_column_information

    default_campus = MigrationCampus.find_or_create_by!(code: "main") do |campus|
      campus.name = "Main Campus"
      campus.location = nil
      campus.active = true
    end

    say_with_time "Backfilling users with default campus" do
      MigrationUser.where(campus_id: nil).update_all(campus_id: default_campus.id)
    end

    say_with_time "Backfilling items with their user's campus" do
      MigrationItem.find_each do |item|
        next if item.campus_id.present?

        user_campus_id = MigrationUser.where(id: item.user_id).pick(:campus_id) || default_campus.id
        item.update_columns(campus_id: user_campus_id)
      end
    end

    change_column_null :users, :campus_id, false
    change_column_null :items, :campus_id, false
  end

  def down
    remove_reference :items, :campus, foreign_key: { to_table: :campuses }
    remove_reference :users, :campus, foreign_key: { to_table: :campuses }
    drop_table :campuses
  end
end
