class RecipesController < ApplicationController
  def index
    @recipes = filtered_recipes

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  # def filtered_recipes
  #   if params['q'].present?
  #     query = params[:q].strip.downcase
  #         title_matches = Recipe.where("LOWER(title) LIKE ?", "%#{query}%")

  #         # Get IDs of recipes already matched by title
  #         matched_ids = title_matches.pluck(:id)

  #         # Ingredient search, excluding already matched IDs
  #         ingredient_list = query.split(',').map(&:strip)
  #         ingredient_matches = Recipe.with_ingredients(ingredient_list).where.not(id: matched_ids)

  #         # Combine both results
  #         title_matches + ingredient_matches
  #   else
  #     Recipe.all
  #   end
  # end
  def filtered_recipes
    return Recipe.all if params[:q].blank?

    query = params[:q].downcase
    keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)

    # Recipes with title matches (ranked by number of keyword matches)
    title_matches = Recipe
      .where(keywords.map { "LOWER(title) LIKE ?" }.join(" OR "), *keywords.map { |kw| "%#{kw}%" })
      .select("recipes.*, (#{keywords.map { |kw| "CASE WHEN LOWER(title) LIKE '%#{kw}%' THEN 1 ELSE 0 END" }.join(" + ")}) AS title_match_count")
      .order("title_match_count DESC")

    # Recipes with ingredient matches (excluding title matches), ranked by count
    ingredient_matches = Recipe
      .joins(:ingredients)
      .where(ingredients: { name: keywords })
      .where.not(id: title_matches.map(&:id))
      .group("recipes.id")
      .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
      .order("ingredient_match_count DESC")

    @recipes = title_matches + ingredient_matches
  end






end
