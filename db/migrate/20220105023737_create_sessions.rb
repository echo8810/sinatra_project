class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.string :session_id  ,unique: true
      t.json   :value_json
    end
    add_index :sessions, [:session_id], unique: true 
  end
end