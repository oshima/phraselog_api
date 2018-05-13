class Api::UsersController < ApplicationController
  before_action :authenticate, only: [:create]
  before_action :find_user, only: [:show]

  def create
    @auth_user.update!(params.permit(:display_name, :photo_url))
  rescue ActiveRecord::RecordInvalid => e
    logger.info(e)
    head :bad_request
  end

  def show
    render json: @user.to_json(only: [:id_string, :display_name, :photo_url])
  end

  private

  def find_user
    @user = User.find_by(id_string: params[:id_string])
    unless @user
      logger.info("Specified user doesn't exist")
      return head(:not_found)
    end
  end
end
