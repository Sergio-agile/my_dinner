module RecipesHelper
  def pagination(pagy)
    content_tag(:div, class: "flex justify-center space-x-2 text-sm mt-5") do
      raw(pagy_nav(pagy)
        .gsub("<span", "<span class='px-2 py-1 bg-gray-100 rounded'")
        .gsub("<a", "<a class='px-2 py-1 border border-gray-300 rounded hover:bg-gray-200'"))
    end
  end
end
