ActiveAdmin.register Item do
  permit_params :title, :description, :item_type, :category, :location, :found_on, :status, :user_id, :campus_id

  index do
    selectable_column
    id_column
    column :item_type
    column :title
    column :category
    column :campus
    column :location
    column :found_on
    column :status
    column :user
    actions
  end

  form do |f|
    f.inputs do
      f.input :item_type
      f.input :title
      f.input :category
      f.input :campus
      f.input :user
      f.input :location
      f.input :found_on, as: :datepicker
      f.input :status
      f.input :description
    end
    f.actions
  end
end
