class MoviesController < ApplicationController
  Tmdb::Api.key(ENV['TMDB_API_KEY'])
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def search_tmdb
    # mock_info = {title:"Inception", rating:"PG", release_date:"31-Apr-2002"}
    # if params[:movie][:title] == "Inception"
    #   @movie_details = mock_info
    # else
    #   flash[:notice] = "'#{params[:movie][:title]}' was not found in TMDb."
    #   redirect_to root_path
    # end
    movies = Tmdb::Movie.find(params[:movie][:title])
    # puts @movies[0]
    if movies.empty?
      flash[:notice] = "'#{params[:movie][:title]}' was not found in TMDb."
      redirect_to root_path
    else
      # flash[:notice] = "'#{movies}'"
      @movie_details = movies[0]
      puts movies[0].release_date
    end
  end

  private

  def force_index_redirect
    if !params.key?(:ratings) || !params.key?(:sort_by)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    Hash[ratings_list.collect { |item| [item, "1"] }]
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
