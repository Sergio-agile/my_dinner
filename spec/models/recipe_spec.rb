require "rails_helper"

RSpec.describe Recipe, type: :model do
  describe "associations" do
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "factories" do
    it "is valid" do
      expect(build(:recipe)).to be_valid
    end
  end

  describe ".order_by_rating" do
    it "orders recipes by ratings" do
      high_rating = create(:recipe, ratings: 10)
      low_rating = create(:recipe, ratings: 5)

      expect(Recipe.order_by_rating).to eq([ high_rating, low_rating ])
    end
  end

  describe ".title_matches" do
    it "finds recipes with matching titles" do
      recipe1 = create(:recipe, title: "Chicken Curry")
      recipe2 = create(:recipe, title: "Beef Stew")

      expect(Recipe.title_matches([ "chicken" ])).to include(recipe1)
      expect(Recipe.title_matches([ "chicken" ])).not_to include(recipe2)
    end
  end

  describe ".filtered_recipes" do
    before do
      @recipe1 = create(:recipe, title: "Spaghetti Carbonara", ratings: 4.5)
      @recipe2 = create(:recipe, title: "Pesto Pasta", ratings: 4.0)

      @pesto = create(:ingredient, name: "Pesto")
      @recipe2.recipe_ingredients.create!(ingredient: @pesto, original_text: "Some original text")
    end

    context "without search query" do
      it "returns all recipes ordered by ratings descending" do
        results = Recipe.filtered_recipes({})
        expect(results).to eq([ @recipe1, @recipe2 ]) # 4.5 > 4.0
      end
    end

    context "with search query matching title" do
      it "returns recipes matching the title" do
        results = Recipe.filtered_recipes(q: "Carbonara")
        expect(results).to include(@recipe1)
        expect(results).not_to include(@recipe2)
      end
    end

    context "with search query matching ingredient" do
      it "returns recipes matching the ingredient" do
        results = Recipe.filtered_recipes(q: "Pesto")
        expect(results).to include(@recipe2)
        expect(results).not_to include(@recipe1)
        expect(@recipe2.ingredients).to include(@pesto)
      end
    end
  end
end
