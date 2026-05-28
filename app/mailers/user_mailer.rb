class UserMailer < ApplicationMailer
  def student_welcome
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Welcome to Campus Lost & Found"
    )
  end

  def faculty_verified
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Your faculty profile is now verified"
    )
  end
end
