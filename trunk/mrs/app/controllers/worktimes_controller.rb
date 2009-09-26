class WorktimesController < ApplicationController

  def index
    user_id = params[:user_id]
    @user = User.find_by_id (user_id)
    @worktimes = @user.worktimes
    if @worktimes == nil       
      respond_to do |format|
        format.html { redirect_to new_worktime_path (@user) }
        format.xml  { render :xml => @worktimes }
      end
    else 
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @worktimes }
      end
    end
  end

  def new 
    @worktime = Worktime.new    
    @places = Place.find(:all)
    @user = User.find_by_id (params[:user_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @worktime }
    end
  end

  def show
  end

  def edit
  end


  def destroy
    @worktime = Worktime.find(params[:id])
    if @worktime.destroy
      respond_to do |format|
        flash[:notice] = 'Worktime was successfully deleted.'
        format.html { redirect_to user_worktimes_path (@worktime.doctor) }
        format.xml  { render :xml => @worktime, :status => :created, :location => @worktime }    
      end
    end
  end


  def create
    @worktime = Worktime.new(params[:worktime])
    respond_to do |format|
      if @worktime.save
        flash[:notice] = 'Worktime was successfully created.'
        format.html { redirect_to user_worktimes_path (@worktime.doctor) }
        format.xml  { render :xml => @worktime, :status => :created, :location => @worktime }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @worktime.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
  end

end
