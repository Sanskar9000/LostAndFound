class VerificationController < ApplicationController
  skip_before_action :authenticate_user!

  def pending
    render layout: false
  end
end