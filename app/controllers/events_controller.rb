class EventsController < ApplicationController
  def index
    if params[:search].blank?  
      @events = Event.all.order('start_datetime ASC')
      render json: @events.as_json(include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    else  
      @parameter = search_params[:search].downcase
      @events = Event.all.where("LOWER(title) LIKE LOWER(:search)", search: "%#{@parameter}%")  
      render json: @events.as_json(include: {user: {only: [:name, :nickname, :image, :id, :email]}})
    end  
  end

  private
  def event_params
    params.require(:event).permit(:user, :user_id, :image_url, :description, :title, :start_datetime, :location)
  end

  def search_params
    params.permit(:search)
  end
end

