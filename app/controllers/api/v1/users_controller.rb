class Api::V1::UsersController < ApplicationController
  def current
    @user = current_user

    return render json: nil, status: 200 unless @user
  end
end
