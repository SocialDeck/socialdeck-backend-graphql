class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.references :user, foreign_key: true
      t.references :author
      t.string :card_name
      t.string :display_name
      t.string :name
      t.string :business_name
      t.references :address, foreign_key: true
      t.string :number
      t.string :email
      t.date :birth_date
      t.string :twitter
      t.string :linked_in
      t.string :facebook
      t.string :instagram

      t.timestamps
    end
  end
end
