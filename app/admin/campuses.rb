ActiveAdmin.register Campus do
  permit_params :name, :code, :location, :active

  index do
    selectable_column
    id_column
    column :name
    column :code
    column :location
    column :active
    column :users_count do |campus|
      campus.users.count
    end
    column :items_count do |campus|
      campus.items.count
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :location
      f.input :active
    end
    f.actions
  end
end
