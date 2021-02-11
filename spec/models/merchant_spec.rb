require 'rails_helper'

RSpec.describe Merchant, type: :model do
  # describe 'validations' do
  # end
  
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_many(:customers).through(:invoices) }
  end

  # describe 'instance methods' do
  # end
end