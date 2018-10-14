class RemoveUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    remove_index :shortlinks, :jwt
    add_index :shortlinks, :jwt
  end
end
