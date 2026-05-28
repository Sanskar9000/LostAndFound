class AddRejectionReasonToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :rejection_reason, :text
  end
end
