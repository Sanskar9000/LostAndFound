module ApplicationHelper
  def expandable_image_tag(source, image_options = {}, button_options = {})
    alt_text = image_options[:alt].presence || "Preview image"
    src = source.is_a?(String) ? asset_path(source) : url_for(source)

    button_classes = ["image-expand-trigger", button_options[:class]].compact.join(" ")
    image_classes = image_options[:class]

    button_tag(
      type: "button",
      class: button_classes,
      data: {
        expandable_image: true,
        image_src: src,
        image_alt: alt_text
      }
    ) do
      image_tag(source, image_options.merge(class: image_classes))
    end
  end

  def index_view_mode(default: "grid")
    params[:view].in?(%w[grid list]) ? params[:view] : default
  end

  def profile_image_source(user)
    user.profile_image.attached? ? user.profile_image : "profile.png"
  end

  def item_preview_source(item)
    item.images.attached? ? item.images.first : "placeholder.svg"
  end

  def claim_preview_source(claim)
    image_file = claim.proof_files.find { |file| file.content_type&.start_with?("image/") }
    image_file || "placeholder.svg"
  end

  def query_params_with_view(view)
    request.query_parameters.merge(view: view)
  end

  def query_params_with_status(status)
    request.query_parameters.merge(status: status)
  end

  def item_status_badge(item)
    item.status.presence || "open"
  end

  def item_recovery_candidate?(item)
    item.item_type == "lost" && item.status == "open"
  end

  def unread_notifications_count(user = current_user)
    return 0 unless user

    user.notifications.unread.count
  end
end
