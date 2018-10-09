class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :name
      t.string :email
      t.boolean :confirmed, default: false

      t.timestamps
    end
    add_index :users, :token, unique: true
    add_index :users, :username, unique: true
  end
end
