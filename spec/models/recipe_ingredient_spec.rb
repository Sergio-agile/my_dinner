require 'rails_helper'

RSpec.describe RecipeIngredient, type: :model do
  describe 'associations' do
    it { should belong_to(:recipe) }
    it { should belong_to(:ingredient) }
  end

  describe 'validations' do
    it { should validate_presence_of(:original_text) }
  end

  describe 'factories' do
    it 'should be valid' do
      expect(FactoryBot.build(:recipe_ingredient)).to be_valid
    end
  end
end
