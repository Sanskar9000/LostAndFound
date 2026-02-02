ActiveAdmin.register Item do
  permit_params :title, :description, :item_type, :category, :location, :found_on, :status, :user_id

  index do
    selectable_column
    id_column
    column :item_type
    column :title
    column :category
    column :location
    column :found_on
    column :status
    column :user
    actions
  end
end