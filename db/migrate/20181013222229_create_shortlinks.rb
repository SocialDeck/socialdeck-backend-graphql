class CreateShortlinks < ActiveRecord::Migration[5.2]
  def change
    create_table :shortlinks do |t|
      t.string :token
      t.string :jwt
      t.datetime :expires_at

      t.timestamps
    end
    add_index :shortlinks, :token, unique: true
    add_index :shortlinks, :jwt, unique: true
  end
end
