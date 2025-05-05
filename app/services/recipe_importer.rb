class RecipeImporter
  require "json"

  def initialize(json_path)
    @json_path = json_path
  end

  def call
    file = File.read(@json_path)
    recipes_data = JSON.parse(file)

    recipes_data.each do |recipe_data|
      create_recipe_with_ingredients(recipe_data)
    end
  end

  private

  def create_recipe_with_ingredients(data)
    recipe = Recipe.create!(
      title: data["title"],
      cook_time: data["cook_time"],
      prep_time: data["prep_time"],
      ratings: data["ratings"],
      cuisine: data["cuisine"],
      category: data["category"],
      author: data["author"],
      image_url: data["image"]
    )

    data["ingredients"].each do |original_text|
      normalized_name = IngredientNormalizer.normalize(original_text)

      next if normalized_name.blank?

      ingredient = Ingredient.find_or_create_by!(name: normalized_name)
      RecipeIngredient.create!(recipe: recipe, ingredient: ingredient, original_text: original_text)
    end
  end
end
