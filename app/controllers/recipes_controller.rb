class RecipesController < ApplicationController
  def index
    @pagy, @recipes = pagy_array(filtered_recipes, items: 12)

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
    return Recipe.all.order(ratings: :desc).includes(:ingredients) if params[:q].blank?

    query = params[:q].to_s.downcase
    keywords = query.split(/[,\s]+/).map(&:strip).reject(&:blank?)

    return Recipe.none if keywords.empty?

    title_matches = find_title_matches(keywords)

    title_match_ids = title_matches.map(&:id)
    ingredient_matches = find_ingredient_matches(keywords, title_match_ids)

    recipe_ids = (title_matches.map(&:id) + ingredient_matches.map(&:id)).uniq
    if recipe_ids.present?
      Recipe.includes(:ingredients).where(id: recipe_ids).sort_by { |recipe|
        combined_ids = title_matches.map(&:id) + ingredient_matches.map(&:id)
        combined_ids.index(recipe.id) || Float::INFINITY
      }
    else
      Recipe.none
    end
  end

  private

  def find_title_matches(keywords)
    score_fragments = []
    conditions = []
    binds = []

    keywords.each do |keyword|
      pattern = "%#{keyword}%"
      conditions << "LOWER(title) LIKE ?"
      binds << pattern

      escaped_pattern = ActiveRecord::Base.connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(keyword)}%")
      score_fragments << "CASE WHEN LOWER(title) LIKE #{escaped_pattern} THEN 1 ELSE 0 END"
    end

    where_clause = conditions.join(" OR ")
    score_expression = score_fragments.join(" + ")

    matching_ids = Recipe.where(where_clause, *binds).pluck(:id)
    return Recipe.none if matching_ids.empty?

    Recipe.includes(:ingredients)
      .where(id: matching_ids)
      .select(Arel.sql("recipes.*, (#{score_expression}) AS title_match_count"))
      .order(Arel.sql("title_match_count DESC, ratings DESC"))
  end

  def find_ingredient_matches(keywords, exclude_ids)
    return Recipe.none if keywords.empty? || exclude_ids.nil?

    Recipe
      .includes(:ingredients)
      .joins(:ingredients)
      .where(ingredients: { name: keywords })
      .where.not(id: exclude_ids)
      .group("recipes.id")
      .select("recipes.*, COUNT(ingredients.id) AS ingredient_match_count")
      .order("ingredient_match_count DESC, ratings DESC")
  end
end
