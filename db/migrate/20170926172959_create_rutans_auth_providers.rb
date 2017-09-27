class CreateRutansAuthProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :rutans_auth_providers do |t|
      t.references :user
      t.string :name, limit: 64, null: false
      t.string :uid, limit: 128, null: false

      t.timestamps
    end
    add_index :rutans_auth_providers, [:name, :uid], unique: true
  end
end
