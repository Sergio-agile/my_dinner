# FactoryBot.define do
#   factory :recipe_ingredient do
#     recipe { create(:recipe) }
#     ingredient { create(:ingredient) }
#     original_text { "1 cup of something" }
#   end
# end
FactoryBot.define do
  factory :recipe_ingredient do
    recipe
    ingredient
    original_text { "Some original text" }
  end
end
