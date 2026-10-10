class CreateDonorProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :donor_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :blood_group, null: false
      t.string  :city,        null: false
      t.string  :phone,       null: false
      t.boolean :available,   null: false, default: true

      t.timestamps
    end
    add_index :donor_profiles, [ :blood_group, :city ]
  end
end
