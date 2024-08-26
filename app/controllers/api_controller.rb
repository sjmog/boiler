class ApiController < ApplicationController
  def admin_status
    render json: { isAdmin: current_user&.admin? || false }
  end
end
