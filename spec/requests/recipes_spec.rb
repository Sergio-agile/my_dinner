require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    before do
      create(:recipe, title: "Carbonara", ratings: 5.0)
      create(:recipe, title: "Pesto Pasta", ratings: 4.0)
    end

    it "returns a successful response" do
      get recipes_path
      expect(response).to have_http_status(:ok)
    end

    it "displays recipes matching a query" do
      get recipes_path, params: { q: "Pesto" }
      expect(response.body).to include("Pesto Pasta")
      expect(response.body).not_to include("Carbonara")
    end
  end

  describe "GET /recipes/:id" do
    let(:recipe) { create(:recipe, title: "Beef Stew") }

    it "shows the recipe" do
      get recipe_path(recipe)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Beef Stew")
    end
  end
end
