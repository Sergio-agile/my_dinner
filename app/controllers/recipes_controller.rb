class RecipesController < ApplicationController
  def index
    @pagy, @recipes = pagy(Recipe.filtered_recipes(params), items: 12)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
