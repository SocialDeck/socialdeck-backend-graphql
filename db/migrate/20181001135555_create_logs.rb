class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.references :user, foreign_key: true
      t.references :contact
      t.references :card, foreign_key: true
      t.date :date
      t.string :text

      t.timestamps
    end
  end
end
