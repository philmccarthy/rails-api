require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  # describe 'validations' do
  #   it { should validate_presence_of :}
  # end

  describe 'relationships' do
    it { should belong_to :item }
    it { should belong_to :invoice }
    it { should have_one(:merchant).through(:item) }
  end

  describe 'instance methods' do
    it '#destroy_empty_invoice' do
      item_1 = create(:item_with_invoices)
      
      expect(Invoice.count).to eq(5)
      
      all_invoices_have_just_item_1 = item_1.invoices.all? do |invoice|
        invoice.items.all? do |item|
          item == item_1
        end
      end
      
      expect(all_invoices_have_just_item_1).to be true
      
      item_2 = create(:item)
      invoice_2 = create(:invoice)
      invoice_2.invoice_items.create!(item: item_1, invoice: invoice_2)
      invoice_2.invoice_items.create!(item: item_2, invoice: invoice_2)
      
      all_invoices_have_just_item_1 = Invoice.all.all? do |invoice|
        invoice.items.all? do |item|
          item == item_1
        end
      end
      
      expect(all_invoices_have_just_item_1).to be false
      
      item_1.destroy

      expect(Invoice.count).to eq(1)
    end
  end
end
