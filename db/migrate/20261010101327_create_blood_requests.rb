class CreateBloodRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :blood_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :patient_name,  null: false
      t.string  :blood_group,   null: false
      t.integer :units_needed,  null: false, default: 1
      t.string  :hospital,      null: false
      t.string  :city,          null: false
      t.date    :needed_by,     null: false
      t.string  :contact_phone, null: false
      t.text    :note

      t.timestamps
    end
    add_index :blood_requests, [ :blood_group, :city ]
  end
end
