class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true

  def self.with_ingredients(ingredient_names)
    joins(:ingredients)
      .where(ingredients: { name: ingredient_names.map(&:downcase) })
      .group("recipes.id")
      .order("COUNT(ingredients.id) DESC")
  end
end
