class AddValidatedToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :validated, :boolean, default: false
  end
end
