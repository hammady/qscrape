class VehiclesController < ApplicationController
  # GET /vehicles
  # GET /vehicles.xml
  def index
    #@vehicles = Vehicle.find(:all, :limit => 20)
    conditions = []
    reset_page = false

    session[:filter] = params[:filter] if params[:filter] != nil
    @filter = session[:filter]

    if params[:toggle_favor] == 'on'
      reset_page = true if session[:favorites] == false
      session[:favorites] = true
    else
      reset_page = true if session[:favorites] == true
      session[:favorites] = false
    end
    
    if @filter and @filter != ''
      conditions = ["(title like :filter or description like :filter)", {:filter => "%#{@filter}%"}]
      reset_page = true
    end
    
    if params[:page]
      @page = params[:page]
    elsif reset_page
      @page = 1
    else
      @page = session[:page] || 1
    end
    session[:page] = @page
    
    @vehicles = Vehicle.where(conditions)
    @vehicles = @vehicles.where(:favorite => true) if session[:favorites]
    @vehicles = @vehicles.order("id DESC").page(@page).per(25)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vehicles }
    end
  end

  # GET /vehicles/1
  # GET /vehicles/1.xml
  def show
    @vehicle = Vehicle.find(params[:id])
    @vehicle.viewed_at = Time.now
    @vehicle.save

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vehicle }
    end
  end

  def favor
    @vehicle = Vehicle.find(params[:id])
    @vehicle.favorite = ! @vehicle.favorite
    @vehicle.save

    respond_to do |format|
      format.html { render :action => "show"} # show.html.erb
      format.xml  { render :xml => @vehicle }
    end
  end
  
  def comment
    @vehicle = Vehicle.find(params[:id])
    @vehicle.comments = params[:text]
    @vehicle.save

    flash[:notice] = "Comment saved successfully"
    respond_to do |format|
      format.html { render :action => "show"} # show.html.erb
      format.xml  { render :xml => @vehicle }
    end
  end

end
