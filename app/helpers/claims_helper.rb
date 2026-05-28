module ClaimsHelper
  def pickup_qr_svg(claim)
    return unless claim.pickup_qr_payload.present?

    RQRCode::QRCode.new(claim.pickup_qr_payload).as_svg(
      color: "111827",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    ).html_safe
  end
end
