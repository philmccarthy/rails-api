require 'rails_helper'

RSpec.describe Item, type: :model do
  # describe 'validations' do
  #   it { should validate_presence_of :}
  # end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  # describe 'instance methods' do
  # end
end