class TopicsController < ApplicationController
  def index
    @topics = Topic.all
    authorize @topics
  end

  def new
    @topic = Topic.new
    authorize @topic
  end

  def show
    @topic = Topic.find(params[:id])
    @posts = @topic.posts
    authorize @topic
  end

  def edit
    @topic = Topic.find(params[:id])
    authorize @topic
  end

  def create
    @topic = Topic.new(params.require(:topic).permit(:name, :description, :public))
    authorize @topic
    if @topic.save
      redirect_to @topic, notice: "topic was saved successfully"
    else
      flash[:error] = "error saving topic, try again!"
      render :edit
    end
  end
end