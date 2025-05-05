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

  def filtered_recipes
    return Recipe.all if params[:q].blank?

    query = params[:q].to_s.downcase
    keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)

    return Recipe.none if keywords.empty?

    # Find recipes that match by title
    title_matches = find_title_matches(keywords)

    # Find recipes that match by ingredient, excluding title matches
    title_match_ids = title_matches.map(&:id)
    ingredient_matches = find_ingredient_matches(keywords, title_match_ids)

    # Combine results
    title_matches + ingredient_matches
  end

  private

  def find_title_matches(keywords)
    # For each keyword, create a scoring fragment safely
    score_fragments = []
    conditions = []
    binds = []

    keywords.each do |keyword|
      pattern = "%#{keyword}%"
      conditions << "LOWER(title) LIKE ?"
      binds << pattern

      # Properly escape the keyword to prevent SQL injection
      escaped_pattern = ActiveRecord::Base.connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(keyword)}%")
      score_fragments << "CASE WHEN LOWER(title) LIKE #{escaped_pattern} THEN 1 ELSE 0 END"
    end

    where_clause = conditions.join(" OR ")
    score_expression = score_fragments.join(" + ")

    # First get the IDs of matching recipes
    matching_ids = Recipe.where(where_clause, *binds).pluck(:id)
    return Recipe.none if matching_ids.empty?

    # Then calculate scores for these recipes
    Recipe.where(id: matching_ids)
         .select(Arel.sql("recipes.*, (#{score_expression}) AS title_match_count"))
         .order(Arel.sql("title_match_count DESC"))
  end

  def find_ingredient_matches(keywords, exclude_ids)
    return Recipe.none if keywords.empty? || exclude_ids.nil?

    Recipe
      .joins(:ingredients)
      .where(ingredients: { name: keywords })
      .where.not(id: exclude_ids)
      .group("recipes.id")
      .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
      .order("ingredient_match_count DESC")
  end
end
