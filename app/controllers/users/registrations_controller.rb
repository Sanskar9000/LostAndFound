module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do |resource|
        if resource.persisted? && resource.respond_to?(:student?) && resource.student? && !resource.confirmed?
          flash[:notice] = I18n.t("devise.registrations.signed_up_but_student_email_verification_pending")
        end
      end
    end

    protected

    def after_inactive_sign_up_path_for(resource)
      if resource.respond_to?(:faculty?) && resource.faculty? && !resource.verified?
        verification_pending_path
      elsif resource.respond_to?(:student?) && resource.student?
        new_user_session_path
      else
        super
      end
    end
  end
end
