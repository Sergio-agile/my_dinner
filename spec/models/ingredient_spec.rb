require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'associations' do
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:recipes).through(:recipe_ingredients) }
  end

  describe 'validations' do
    subject { create(:ingredient, name: 'Salt') }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'factories' do
    it 'should be valid' do
      expect(FactoryBot.build(:ingredient)).to be_valid
    end
  end

  describe 'case insensitive uniqueness' do
    it 'should not allow duplicate names with different case' do
      create(:ingredient, name: 'Salt')
      ingredient = build(:ingredient, name: 'salt')
      expect(ingredient).to_not be_valid
      expect(ingredient.errors[:name]).to include("has already been taken")
    end
  end
end
