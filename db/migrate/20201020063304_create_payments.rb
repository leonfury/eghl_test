class CreatePayments < ActiveRecord::Migration[6.0]
    def change
        create_table :payments do |t|
            t.integer :payment_status, default: 0, null: false
            t.string :details

            t.timestamps
        end
    end
end
