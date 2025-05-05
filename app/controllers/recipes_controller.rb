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
  # def filtered_recipes
  #   return Recipe.all if params[:q].blank?

  #   query = params[:q].downcase
  #   keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)

  #   # Recipes with title matches (ranked by number of keyword matches)
  #   title_matches = Recipe
  #     .where(keywords.map { "LOWER(title) LIKE ?" }.join(" OR "), *keywords.map { |kw| "%#{kw}%" })
  #     .select("recipes.*, (#{keywords.map { |kw| "CASE WHEN LOWER(title) LIKE '%#{kw}%' THEN 1 ELSE 0 END" }.join(" + ")}) AS title_match_count")
  #     .order("title_match_count DESC")

  #   # Recipes with ingredient matches (excluding title matches), ranked by count
  #   ingredient_matches = Recipe
  #     .joins(:ingredients)
  #     .where(ingredients: { name: keywords })
  #     .where.not(id: title_matches.map(&:id))
  #     .group("recipes.id")
  #     .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
  #     .order("ingredient_match_count DESC")

  #   @recipes = title_matches + ingredient_matches
  # end
  # def filtered_recipes
  #   return Recipe.all if params[:q].blank?

  #   query = params[:q].to_s.downcase
  #   keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)

  #   return Recipe.none if keywords.empty?

  #   # WHERE clause for title matching
  #   where_clauses = keywords.map { "LOWER(title) LIKE ?" }.join(" OR ")
  #   where_values = keywords.map { |kw| "%#{kw}%" }

  #   # Build scoring expression safely with sanitized values
  #   title_score_expr = keywords.map do |kw|
  #     sanitized_kw = ActiveRecord::Base.connection.quote("%#{kw}%")
  #     "CASE WHEN LOWER(title) LIKE #{sanitized_kw} THEN 1 ELSE 0 END"
  #   end.join(" + ")

  #   title_matches = Recipe
  #     .where(where_clauses, *where_values)
  #     .select("recipes.*, (#{title_score_expr}) AS title_match_count")
  #     .order("title_match_count DESC")

  #   # Ingredient match, excluding already found recipes
  #   title_match_ids = title_matches.map(&:id)

  #   ingredient_matches = Recipe
  #     .joins(:ingredients)
  #     .where(ingredients: { name: keywords })
  #     .where.not(id: title_match_ids)
  #     .group("recipes.id")
  #     .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
  #     .order("ingredient_match_count DESC")

  #   @recipes = title_matches + ingredient_matches
  # end

  def filtered_recipes
    return Recipe.all if params[:q].blank?

    query = params[:q].to_s.downcase
    keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)
    return Recipe.none if keywords.empty?

    # Title match
    where_clauses = keywords.map { "LOWER(title) LIKE ?" }.join(" OR ")
    where_values = keywords.map { |kw| "%#{kw}%" }

    # Title score with sanitized literals (done outside interpolation to help Brakeman)
    scoring_parts = keywords.map do |kw|
      sanitized = ActiveRecord::Base.connection.quote("%#{kw}%")
      "CASE WHEN LOWER(title) LIKE #{sanitized} THEN 1 ELSE 0 END"
    end
    title_score_sql = scoring_parts.join(" + ")

    # Explicit select columns to help Brakeman
    base_select = "recipes.*, (#{title_score_sql}) AS title_match_count"

    title_matches = Recipe
      .where(where_clauses, *where_values)
      .select(base_select)
      .order("title_match_count DESC")

    title_match_ids = title_matches.map(&:id)

    ingredient_matches = Recipe
      .joins(:ingredients)
      .where(ingredients: { name: keywords })
      .where.not(id: title_match_ids)
      .group("recipes.id")
      .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
      .order("ingredient_match_count DESC")

    @recipes = title_matches + ingredient_matches
  end

end
