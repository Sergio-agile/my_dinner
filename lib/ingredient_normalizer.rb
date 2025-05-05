require "active_support/inflector"

class IngredientNormalizer
  UNITS = %w[
    cup cups tablespoon tablespoons teaspoon teaspoons ounce ounces
    fluid fluid ounce ounces package packages can cans sheet sheets
    slice slices pint pints quart quarts gallon gallons pound pounds
    gram grams kilogram kilograms stick sticks dash pinch clove cloves
    bunch bunches head heads taste inchs
  ].freeze

  PREPARATIONS = %w[cubed diced minced chopped sliced melted softened melted grated shredded juiced seeded pitted peeled crushed packed scalded warm hot cold cooked uncooked fresh dried ground whole finely coarsely roughly halved quartered pitted mashed pureed toasted roasted steamed blanched cut mix].freeze

  ADJECTIVES = %w[
    active all-purpose bitter boneless brown burnt chopped condensed confectioners cooked crisp crunchy creamy dark dense diced dry evaporated firm flaky fluffy fresh golden granulated greasy hard heavy hot juicy large lean light
    mashed meaty medium minced moist oily powdered raw ripe runny salty salted seeded semi-sweet shredded skinless small smooth soft sour
    spicy stale sweet sweetened tender thick thin tough unripe unseeded unsalted unsweetened white whipping
  ].freeze

  ADVERBS = %w[
    thinly thickly finely coarsely roughly gently firmly evenly lightly heavily
    partially fully freshly separately together quickly slowly
  ].freeze

  PREPOSITIONS = %w[of for with in to from into as].freeze

  CONJUNCTIONS = %w[and or].freeze

  def self.normalize(ingredient)
    part = ingredient.split(/\s+(?:or|and)\s+/i).first

    part = part
      .downcase
      .gsub(/\(.*?\)/, "")                             # remove anything in parentheses
      .gsub(/[\u00BC-\u00BE\u2150-\u215E]/, "")        # remove uncommon unicode fractions
      .gsub(/\A[\d\s\/\.\-]+/, "")                     # remove leading quantities and punctuation
      .gsub(/\b(#{UNITS.join("|")})\b/, "")
      .gsub(/\b(#{PREPARATIONS.join("|")})\b/, "")
      .gsub(/\b(#{ADJECTIVES.join("|")})\b/, "")
      .gsub(/\b(#{ADVERBS.join("|")})\b/, "")
      .gsub(/\b(#{PREPOSITIONS.join("|")})\b/, "")
      .gsub(/\b(#{CONJUNCTIONS.join("|")})\b/, "")
      .gsub(/\b\w+ed\b/, "")                          # remove verbs ending in -ed
      .gsub(/\b\w+ing\b/, "")                         # remove verbs ending in -ing
      .gsub(/"s\b/, "")                               # remove possessive endings
      .gsub(/[\-,\.]/, "")                            # remove punctuation
      .gsub(/\s+/, " ")                               # normalize whitespace
      .strip
      .singularize

    part || ""
  end
end
