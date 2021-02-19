require 'rails_helper'

RSpec.describe Invoice, type: :model do
  # describe 'validations' do
  #   it { should validate_presence_of :}
  # end

  describe 'relationships' do
    it { should belong_to :customer }
    it { should belong_to :merchant }
    it { should have_many :transactions }
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe 'class methods' do
    it '::unshipped_potential_revenue' do
      invoice = create(:invoice, status: 'packaged')
      create(:invoice_item, invoice: invoice, quantity: 1, unit_price: 100.00)

      unshipped_invoice_with_revenue = Invoice.unshipped_potential_revenue(1)

      expect(unshipped_invoice_with_revenue).to be_an ActiveRecord::Relation
      expect(unshipped_invoice_with_revenue.first.id).to eq(invoice.id)
      expect(unshipped_invoice_with_revenue.first.potential_revenue).to eq(100)
    end
  end
end