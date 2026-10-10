class CreateResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :responses do |t|
      t.references :blood_request, null: false, foreign_key: true
      t.references :donor, null: false, foreign_key: { to_table: :users }
      t.text :note

      t.timestamps
    end
    add_index :responses, [ :blood_request_id, :donor_id ], unique: true
  end
end
