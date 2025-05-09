require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'associations' do
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'factories' do
    it 'should be valid' do
      expect(build(:recipe)).to be_valid
    end
  end
end
