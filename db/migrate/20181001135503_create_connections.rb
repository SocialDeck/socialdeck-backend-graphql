class CreateConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :connections do |t|
      t.references :user, foreign_key: true
      t.references :contact
      t.references :card, foreign_key: true

      t.timestamps
    end
  end
end
