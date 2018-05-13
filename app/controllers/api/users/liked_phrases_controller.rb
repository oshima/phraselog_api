class Api::Users::LikedPhrasesController < ApplicationController
  before_action :authenticate, only: [:create, :destroy]
  before_action :forbid, only: [:create, :destroy]
  before_action :find_user, only: [:index, :show]
  before_action :find_phrase, only: [:create, :show, :destroy]
  before_action :paginate, only: [:index]

  def index
    likes = Like.where(user: @user)
      .order(created_at: :desc)
      .offset(16 * (@page - 1))
      .limit(16)
    phrase_ids = likes.map(&:phrase_id)
    phrases = Phrase.includes(:likes, :user)
      .where(id: phrase_ids)
      .order(['field(id, ?)', phrase_ids])
    render json: phrases.to_json(
      only: [:id_string, :title, :interval, :created_at, :updated_at],
      methods: [:likes_count],
      include: { user: { only: [:id_string, :display_name, :photo_url] } }
    )
  end

  def create
    Like.create(user: @auth_user, phrase: @phrase)
  end

  def show
    like = Like.find_by(user: @user, phrase: @phrase)
    render json: like ? { id_string: @phrase.id_string } : nil
  end

  def destroy
    Like.where(user: @auth_user, phrase: @phrase).delete_all
  end

  private

  def forbid
    unless params[:user_id_string] == @auth_user.id_string
      logger.info("Specified user isn't authenticated user")
      return head(:forbidden)
    end
  end

  def find_user
    @user = User.find_by(id_string: params[:user_id_string])
    unless @user
      logger.info("Specified user doesn't exist")
      return head(:not_found)
    end
  end

  def find_phrase
    @phrase = Phrase.find_by(id_string: params[:id_string])
    unless @phrase
      logger.info("Specified phrase doesn't exist")
      return head(:not_found)
    end
  end

  def paginate
    page = params[:p].to_i
    @page = page > 0 ? page : 1
  end
end
