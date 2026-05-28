class ItemMailer < ApplicationMailer
  def found_match_notification
    @lost_item = params[:lost_item]
    @found_item = params[:found_item]
    @reporter = params[:reporter]

    mail(
      to: @lost_item.user.email,
      subject: "Someone may have found your lost item"
    )
  end
end
