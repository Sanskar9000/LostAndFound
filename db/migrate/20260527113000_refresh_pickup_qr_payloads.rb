class RefreshPickupQrPayloads < ActiveRecord::Migration[7.1]
  class MigrationClaim < ApplicationRecord
    self.table_name = "claims"
  end

  def up
    host_options = Rails.application.config.action_mailer.default_url_options || {}

    say_with_time "Refreshing pickup QR payloads to use web URLs" do
      MigrationClaim.where.not(pickup_token: [nil, ""]).find_each do |claim|
        url = Rails.application.routes.url_helpers.pickup_verification_url(
          claim.pickup_token,
          host: host_options[:host] || "localhost",
          port: host_options[:port]
        )

        claim.update_columns(pickup_qr_payload: url)
      end
    end
  end

  def down
    MigrationClaim.where.not(pickup_token: [nil, ""]).find_each do |claim|
      claim.update_columns(
        pickup_qr_payload: "pickup://claim/#{claim.id}?token=#{claim.pickup_token}"
      )
    end
  end
end
