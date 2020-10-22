class Payment < ApplicationRecord
    enum payment_status: [:unknown, :success, :failure, :pending]
end
