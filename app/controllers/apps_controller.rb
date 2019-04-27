class AppsController < ApplicationController
  before_action :set_app, only: [:show, :edit, :update, :destroy]
  skip_before_filter :logged_in?, :only => :index
  skip_before_filter :auth_user?, :only => :index
  @@all_length = App.all.length

  # GET /apps
  # GET /apps.json
  def index
    @current_user = User.find_by_id(session[:user_id])

    if !params[:page_num].nil? && session[:page_num].nil? then
      session[:page_num] = 1    
    end
    if !params[:each_page].nil? then
      session[:each_page] = params[:each_page]
      session[:page_num] = 1
    elsif session[:each_page].nil? then
      session[:each_page] = '10'
    end

    @each_page_str = session[:each_page]
    @page_num = session[:page_num].to_i
    if @each_page_str == 'All' then
      @each_page = @@all_length
    else
      @each_page = @each_page_str.to_i
    end
    max_page_num =  (@@all_length - 1) / @each_page + 1
    if params[:page_num] == "prv" then
      if @page_num > 1 then
	@page_num = @page_num - 1
	flash[:page_num] = ""
      else
	flash[:page_num] = "You are already on the FIRST page."
      end
    elsif params[:page_num] == "nxt" then
      if @page_num < max_page_num then
	@page_num = @page_num + 1
	flash[:page_num] = ""
      else
	flash[:page_num] = "You are already on the LAST page."
      end
    else
      flash[:page_num] = ""
    end
    session[:page_num] = @page_num.to_s
    @apps = App.limit(@each_page).offset(@each_page*(@page_num-1))
    
    respond_to do |format|
      format.json { render :json => @apps.featured }
      format.html
    end
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
  end

  # GET /apps/new
  def new
    if User.find_by_id(session[:user_id]).coach?
      @app = App.new
    else
      redirect_to apps_path, alert: 'Error: Only Staff can create an app'
    end
  end

  # GET /apps/1/edit
  def edit
    if User.find_by_id(session[:user_id]).coach?
      @comments = App.find_by_id(params[:id]).comments
    else
      redirect_to apps_path, alert: 'Error: Only Staff can edit an app'
    end
  end

  # POST /apps
  # POST /apps.json
  def create
    @app = App.new(app_params)

    respond_to do |format|
      if @app.save
        format.html { redirect_to apps_path, notice: 'App was successfully created.' }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apps/1
  # PATCH/PUT /apps/1.json
  def update
    respond_to do |format|
      if @app.update(app_params)
        format.html { redirect_to apps_path, notice: 'App was successfully updated.' }
        format.json { render :show, status: :ok, location: @app }
      else
        format.html { render :action => :edit }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    if User.find_by_id(session[:user_id]).coach?
      @app.destroy
      respond_to do |format|
        format.html { redirect_to apps_url, notice: 'App was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to apps_path, alert: 'Error: Only Staff can destroy an app'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
      @engagements = @app.engagements
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_params
      params.require(:app).permit(:name, :description, :deployment_url, :repository_url, :code_climate_url, :org_id, :status, :comments)
    end
end 
