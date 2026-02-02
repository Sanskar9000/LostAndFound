class AddApprovedAtToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :approved_at, :datetime
  end
end
