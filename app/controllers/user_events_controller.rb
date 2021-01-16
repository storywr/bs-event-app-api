class UserEventsController < ApplicationController
  before_action :get_user

  def index
    if params[:search].blank?  
      @events = @user.events.order('start_datetime ASC')
      render json: @events.as_json(include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    else  
      @parameter = search_params[:search].downcase
      @events = @user.events.where("LOWER(title) LIKE LOWER(:search)", search: "%#{@parameter}%")
      render json: @events.as_json(include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    end
  end

  def show
    @event = Event.find(params[:id])
    render json: @event.as_json(except: :user_id, include: {user: {only: [:name, :nickname, :image, :id, :email]}})
                        .merge(currentUserCanEdit: @event.user.email == request.headers['uid'])
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      render @event.as_json(except: :user_id, include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.update(event_params)
      render json: @event.as_json(except: :user_id, include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    if @event.destroy
      head :no_content, status: :ok
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  private
    def event_params
      params.require(:event).permit(:user_id, :image_url, :description, :title, :start_datetime, :location)
    end

    def get_user
      @user = User.find(params[:user_id])
    end

    def search_params
      params.permit(:search)
    end
end

