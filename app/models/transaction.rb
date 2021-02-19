# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :invoice
  has_many :invoice_items, through: :invoice
  has_many :items, through: :invoice
  has_one :merchant, through: :invoice
end
