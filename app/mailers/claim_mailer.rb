class ClaimMailer < ApplicationMailer
  def approved
    @claim = params[:claim]
    @item = @claim.item

    mail(
      to: @claim.user.email,
      subject: "Your claim has been approved"
    )
  end

  def rejected
    @claim = params[:claim]
    @item = @claim.item

    mail(
      to: @claim.user.email,
      subject: "Your claim has been rejected"
    )
  end
end
