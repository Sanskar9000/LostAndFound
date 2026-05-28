ActiveAdmin.register User do
  permit_params :email, :role, :department, :verified, :campus_id

  scope :all, default: true
  scope("Students") { |s| s.where(role: "student") }
  scope("Faculty")  { |s| s.where(role: "faculty") }
  scope("Unverified Faculty") { |s| s.where(role: "faculty", verified: false) }

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :campus
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
    just_verified = resource.faculty? && !resource.verified?
    resource.update!(verified: true)
    if just_verified
      Notification.notify!(
        recipient: resource,
        title: "Faculty profile verified",
        body: "Your faculty profile has now been verified. You can sign in and continue using the app.",
        kind: :faculty_verified,
        link_path: "/users/sign_in"
      )
      UserMailer.with(user: resource).faculty_verified.deliver_now
    end
    redirect_to resource_path, notice: "Faculty verified successfully."
  end

  member_action :unverify, method: :put do
    resource.update!(verified: false)
    redirect_to resource_path, notice: "Faculty unverified."
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :campus
      f.input :role, as: :select, collection: %w[student faculty admin]
      f.input :department
      f.input :verified
    end
    f.actions
  end
end
