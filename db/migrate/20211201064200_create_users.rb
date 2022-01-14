class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name  ,unique: true
      t.string :email ,unique: true
      t.string :password
      t.timestamps
    end
    add_index :users, [:name, :email], unique: true 
  end
end
