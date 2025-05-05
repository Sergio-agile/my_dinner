class SearchController < ApplicationController
  def index
    @recipes = Recipe.where("title ILIKE ?", "%#{params[:q]}%")

    respond_to do |format|
      format.turbo_stream { render partial: "shared/search_results", locals: { recipes: @recipes } }
    end
  end
end
