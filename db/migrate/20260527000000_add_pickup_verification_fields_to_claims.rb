class AddPickupVerificationFieldsToClaims < ActiveRecord::Migration[7.1]
  class MigrationClaim < ApplicationRecord
    self.table_name = "claims"
  end

  def up
    add_column :claims, :pickup_token, :string
    add_column :claims, :pickup_qr_payload, :text
    add_column :claims, :pickup_verified_at, :datetime
    add_reference :claims, :pickup_verified_by, foreign_key: { to_table: :users }

    add_index :claims, :pickup_token, unique: true

    MigrationClaim.reset_column_information

    say_with_time "Backfilling pickup tokens for existing approved claims" do
      MigrationClaim.where(status: "approved", pickup_token: nil).find_each do |claim|
        token = loop do
          candidate = SecureRandom.urlsafe_base64(24)
          break candidate unless MigrationClaim.exists?(pickup_token: candidate)
        end

        claim.update_columns(
          pickup_token: token,
          pickup_qr_payload: "pickup://claim/#{claim.id}?token=#{token}"
        )
      end
    end
  end

  def down
    remove_index :claims, :pickup_token
    remove_reference :claims, :pickup_verified_by, foreign_key: { to_table: :users }
    remove_column :claims, :pickup_verified_at
    remove_column :claims, :pickup_qr_payload
    remove_column :claims, :pickup_token
  end
end
