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

  # describe 'instance methods' do
  # end
end