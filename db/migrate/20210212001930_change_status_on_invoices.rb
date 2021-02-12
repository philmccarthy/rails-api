class ChangeStatusOnInvoices < ActiveRecord::Migration[5.2]
  def change
    change_column :invoices, 
      :status,
      :integer,
      using: "(CASE status 
                WHEN 'packaged' THEN '1'::integer 
                WHEN 'shipped' THEN '2'::integer
                WHEN 'returned' THEN '3'::integer
                ELSE '0'::integer
              END)", default: 0
  end
end
