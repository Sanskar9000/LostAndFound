ActiveAdmin.register Claim do
  permit_params :status

  actions :all, except: [:new, :edit]

  index do
    selectable_column
    id_column
    column :item do |c|
      c.item&.title
    end
    column :user do |c|
      c.user&.email
    end
    column :status
    column :claim_code
    column :created_at
    actions defaults: true do |c|
      if c.status == "pending"
        item "Approve", approve_admin_claim_path(c),
             method: :put, class: "member_link"
        item "Reject", reject_admin_claim_path(c),
             method: :put, class: "member_link"
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :item
      row :user
      row :status
      row :claim_code
      row :proof_note
      row :created_at
    end
  end

  member_action :approve, method: :put do
    resource.update!(status: "approved")

    # Optional: mark item as returned when approved (nice for report)
    resource.item.update!(status: "returned") if resource.item.present?

    redirect_to resource_path, notice: "Claim approved."
  end

  member_action :approve, method: :put do
    resource.update!(status: "approved", approved_at: Time.current)

    # Optional: mark item as returned when approved
    resource.item.update!(status: "returned") if resource.item.present?

    redirect_to resource_path, notice: "Claim approved."
  end

  member_action :reject, method: :put do
    resource.update!(status: "rejected")
    redirect_to resource_path, notice: "Claim rejected."
  end
end