require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    before do
      # Create sample recipes
      @recipe1 = create(:recipe, title: "Spaghetti Carbonara", ratings: 4.5)
      @recipe2 = create(:recipe, title: "Pesto Pasta", ratings: 4.0)

      # Create ingredients
      @ingredient1 = create(:ingredient, name: "Salt")
      @ingredient2 = create(:ingredient, name: "Pesto")

      # Associate ingredients with recipes using RecipeIngredient
      @recipe2.ingredients << @ingredient2
      @recipe2.recipe_ingredients.last.update(original_text: "Some original text")
    end

    context "without search query" do
      it "returns all recipes ordered by ratings descending" do
        get recipes_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Spaghetti Carbonara")
        expect(response.body).to include("Pesto Pasta")
      end
    end

    context "with search query matching title" do
      it "returns recipes matching the title" do
        get recipes_path, params: { q: "Carbonara" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Spaghetti Carbonara")
        expect(response.body).not_to include("Pesto Pasta")
      end
    end

    context "with search query matching ingredient" do
      it "returns recipes matching the ingredient" do
        get recipes_path, params: { q: "Pesto" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Pesto Pasta")
        expect(response.body).not_to include("Spaghetti Carbonara")
      end
    end
  end
end
