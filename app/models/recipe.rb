class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true

  scope :order_by_rating, -> { order(ratings: :desc).includes(:ingredients) }

  scope :title_matches, ->(keywords) {
    score_fragments = keywords.map do |keyword|
      sanitized = ActiveRecord::Base.sanitize_sql_like(keyword)
      "CASE WHEN LOWER(title) LIKE '%#{sanitized}%' THEN 1 ELSE 0 END"
    end

    score_expression = score_fragments.join(" + ")

    select("recipes.id, (#{score_expression}) AS title_match_count, 0 AS ingredient_match_count")
      .where(keywords.map { "LOWER(title) LIKE ?" }.join(" OR "), *keywords.map { |kw| "%#{kw}%" })
  }

  scope :ingredient_matches, ->(keywords) {
    joins(:ingredients)
      .where(ingredients: { name: keywords })
      .select("recipes.id, 0 AS title_match_count, COUNT(ingredients.id) AS ingredient_match_count")
      .group("recipes.id")
  }

  scope :combined_matches, ->(keywords) {
    title_sql = title_matches(keywords).to_sql
    ingredient_sql = ingredient_matches(keywords).to_sql
    combined_sql = "#{title_sql} UNION ALL #{ingredient_sql}"

    from("(#{combined_sql}) AS combined_matches")
      .joins("JOIN recipes ON recipes.id = combined_matches.id")
      .includes(:ingredients)
      .select(
        "recipes.*, " \
        "SUM(combined_matches.title_match_count) AS title_match_count, " \
        "SUM(combined_matches.ingredient_match_count) AS ingredient_match_count"
      )
      .group("recipes.id")
  }

  scope :order_clause, ->(sort) {
    if sort == "rating"
      order("recipes.ratings DESC, SUM(combined_matches.title_match_count) DESC, SUM(combined_matches.ingredient_match_count) DESC")
    else
      order("SUM(combined_matches.title_match_count) DESC, recipes.ratings DESC, SUM(combined_matches.ingredient_match_count) DESC")
    end
  }

  def self.filtered_recipes(params)
    return order_by_rating if params[:q].blank?

    keywords = parse_keywords(params[:q])

    combined_matches(keywords)
      .order_clause(params[:sort])
  end

  private

  def self.parse_keywords(query)
    query.to_s.downcase.split(/[,\s]+/).map(&:strip).reject(&:blank?)
  end
end
