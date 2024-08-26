class AddDeletedAtToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :deleted_at, :datetime
    add_index :products, :deleted_at
  end
end
