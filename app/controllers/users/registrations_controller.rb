class Users::RegistrationsController < Devise::RegistrationsController
  def new_or_sign_in
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  def create
    # Try to find an existing user
    user = User.find_by(email: sign_up_params[:email])

    if user
      if user.valid_password?(sign_up_params[:password])
        # User exists and password is correct, sign them in
        sign_in(user)
        respond_with user, location: "#{after_sign_in_path_for(user)}?toast=signed_in"
      else
        # User exists but password is incorrect, redirect to sign in/up page
        flash[:notice] = "Invalid email or password."
        redirect_to new_user_session_path
      end
    else
      # User doesn't exist, create a new user
      build_resource(sign_up_params)
      resource.save
      if resource.persisted?
        if resource.active_for_authentication?
          sign_up(resource_name, resource)
          respond_with resource, location: "#{after_sign_up_path_for(resource)}?toast=signed_up"
        else
          expire_data_after_sign_in!
          respond_with resource, location: "#{after_inactive_sign_up_path_for(resource)}?toast=signed_up_but#{resource.inactive_message}"
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end

  private

  def sign_in_params
    params.fetch(:user, {}).permit(:email, :password, :remember_me)
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { methods: methods, only: [:password] }
  end
end
