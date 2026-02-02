ActiveAdmin.register User do
  permit_params :email, :role, :department, :verified

  scope :all, default: true
  scope("Students") { |s| s.where(role: "student") }
  scope("Faculty")  { |s| s.where(role: "faculty") }
  scope("Unverified Faculty") { |s| s.where(role: "faculty", verified: false) }

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :department
    column :verified
    column :created_at
    actions defaults: true do |u|
      if u.role == "faculty"
        if u.verified?
          item "Unverify", unverify_admin_user_path(u), method: :put
        else
          item "Verify", verify_admin_user_path(u), method: :put
        end
      end
    end
  end

  member_action :verify, method: :put do
    resource.update!(verified: true)
    redirect_to resource_path, notice: "Faculty verified successfully."
  end

  member_action :unverify, method: :put do
    resource.update!(verified: false)
    redirect_to resource_path, notice: "Faculty unverified."
  end
end