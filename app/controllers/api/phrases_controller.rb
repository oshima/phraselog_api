class Api::PhrasesController < ApplicationController
  before_action :authenticate, only: [:create, :update, :destroy]
  before_action :find_phrase, only: [:show, :update, :destroy]
  before_action :forbid, only: [:update, :destroy]
  before_action :validate_notes, only: [:create, :update]
  before_action :paginate, only: [:index]

  def index
    phrases = Phrase.includes(:likes, :user)
      .order(created_at: :desc)
      .offset(16 * (@page - 1)).
      limit(16)
    render json: phrases.to_json(
      only: [:id_string, :title, :interval, :created_at, :updated_at],
      methods: [:likes_count],
      include: { user: { only: [:id_string, :display_name, :photo_url] } }
    )
  end

  def create
    ActiveRecord::Base.transaction do
      phrase = Phrase.create!(
        id_string: issue_id_string,
        title: params[:title],
        interval: params[:interval],
        user: @auth_user
      )
      notes = params[:notes].map do |n|
        Note.new(x: n[:x], y: n[:y], length: n[:length], phrase: phrase)
      end
      Note.import!(notes)
    end
  rescue ActiveRecord::RecordInvalid => e
    logger.info(e)
    head :bad_request
  end

  def show
    render json: @phrase.to_json(
      only: [:id_string, :title, :interval, :created_at, :updated_at],
      methods: [:likes_count],
      include: {
        user: { only: [:id_string, :display_name, :photo_url] },
        notes: { only: [:x, :y, :length] }
      }
    )
  end

  def update
    ActiveRecord::Base.transaction do
      @phrase.assign_attributes(params.permit(:title, :interval))
      @phrase.changed? ? @phrase.save : @phrase.touch
      Note.where(phrase: @phrase).delete_all
      notes = params[:notes].map do |n|
        Note.new(x: n[:x], y: n[:y], length: n[:length], phrase: @phrase)
      end
      Note.import!(notes)
    end
  rescue ActiveRecord::RecordInvalid => e
    logger.info(e)
    head :bad_request
  end

  def destroy
    @phrase.destroy
  end

  private

  def find_phrase
    @phrase = Phrase.find_by(id_string: params[:id_string])
    unless @phrase
      logger.info("Specified phrase doesn't exist")
      return head(:not_found)
    end
  end

  def forbid
    unless @phrase.user_id == @auth_user.id
      logger.info("Specified phrase isn't authendicated user's own")
      return head(:forbidden)
    end
  end

  def validate_notes
    notes = params[:notes]
    conditions = [
      -> { notes.is_a?(Array) },
      -> { notes.size.in?(1..1000) },
      -> { notes.all? { |n| n.is_a?(ActionController::Parameters) } }
    ]
    unless conditions.all?(&:call)
      logger.info("Received JSON has no or invalid 'notes'")
      return head(:bad_request)
    end
  end

  def paginate
    page = params[:p].to_i
    @page = page > 0 ? page : 1
  end

  def issue_id_string
    loop do
      random = SecureRandom.alphanumeric(8)
      break random unless Phrase.exists?(id_string: random)
    end
  end
end
