class CreateRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, foreign_key: true, null: false
      t.references :ingredient, foreign_key: true, null: false
      t.string :original_text
      t.index [ :recipe_id, :ingredient_id ]
      t.timestamps
    end
  end
end
