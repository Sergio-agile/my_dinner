FactoryBot.define do
  factory :recipe do
    title { "Carbonara" }
    prep_time { 10 }
    cook_time { 20 }
    ratings { 4.5 }
    cuisine { "Italian" }
    category { "Pasta" }
    author { "Chef Mario" }
    image_url { "https://example.com/image.jpg" }
  end
end
