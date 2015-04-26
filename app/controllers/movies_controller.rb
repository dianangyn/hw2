class MoviesController < ApplicationController

 before_filter :authorize, only: [:edit, :update]
 
 skip_before_filter :set_current_user, only: [:index] 

   def index
    @movies = Movie.all
  end
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.html.haml by default
  end
  def index
    #declaring @all_ratings as all movie ratings (unique ones)
    @all_ratings = Movie.all_ratings
  
    #if user selects a rating then hash the movies, with each key being each individual movie
    if params[:ratings]
      @ratings_hash = params[:ratings]
      @ratings_array = params[:ratings].keys
      session[:ratings] = @ratings_hash
    #else if not then sort what is there 
    elsif session[:ratings]
      flash.keep
      redirect_to params.merge(:ratings => session[:ratings])
    else
    #else if nothing selected then sort all movies since that is our default where everything is selected** 
      @ratings_hash = {}
      @ratings_array = @all_ratings
    end
    
    #if user selects a clickable link either by title/release_date sort by that and highlight that specific header
    if params[:sort_by]
      session[:sort_by] = params[:sort_by]
      if (params[:sort_by] == "title")
        @title_header_class = "hilite"
      elsif (params[:sort_by] == "release_date")
        @release_date_header_class = "hilite"
      end
    #if they selected a rating and a clickable link, only sort by the movies that show under that rating
    elsif session[:sort_by] && params[:ratings]
      flash.keep
      redirect_to params.merge(:sort_by => session[:sort_by])
    end

    @movies = Movie.find_all_by_rating(@ratings_array, :order =>  session[:sort_by])
  end

  def new
      @movie = Movie.new
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
   @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    if @movie.update_attributes(params[:movie])
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    else
      render 'edit' # note, 'edit' template can access @movie's field values!
    end
  end


  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def search_tmdb
    # hardwire to simulate failure
    # This was the sad path    
    # flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
    #redirect_to movies_path

    # To  run Rspec test spec 1
    @movies = Movie.find_in_tmdb(params[:search_terms])

  end

end
