require 'rails_helper'

RSpec.describe Customer, type: :model do
  # describe 'validations' do
    # it { should validate_presence_of :}
  # end

  describe 'relationships' do
    it { should have_many :invoices }
    it { should have_many(:merchants).through(:invoices) }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_many(:items).through(:invoice_items) }
  end

  # describe 'instance methods' do
  # end
end