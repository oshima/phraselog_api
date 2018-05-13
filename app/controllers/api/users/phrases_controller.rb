class Api::Users::PhrasesController < ApplicationController
  before_action :find_user
  before_action :paginate

  def index
    phrases = Phrase.includes(:likes, :user)
      .where(user: @user)
      .order(created_at: :desc)
      .offset(16 * (@page - 1))
      .limit(16)
    render json: phrases.to_json(
      only: [:id_string, :title, :interval, :created_at, :updated_at],
      methods: [:likes_count],
      include: { user: { only: [:id_string, :display_name, :photo_url] } }
    )
  end

  private

  def find_user
    @user = User.find_by(id_string: params[:user_id_string])
    unless @user
      logger.info("Specified user doesn't exist")
      return head(:not_found)
    end
  end

  def paginate
    page = params[:p].to_i
    @page = page > 0 ? page : 1
  end
end
