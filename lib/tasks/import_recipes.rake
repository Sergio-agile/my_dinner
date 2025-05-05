require "rails/all"

namespace :import do
  desc "Import recipes from JSON file"
  task recipes: :environment do
    puts "Cleaning database..."

    RecipeIngredient.delete_all
    Ingredient.delete_all
    Recipe.delete_all

    puts "Importing recipes..."
    importer = RecipeImporter.new(Rails.root.join("db", "seeds", "recipes-en.json"))
    importer.call

    puts "Done!"
  end
end
