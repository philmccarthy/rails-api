class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def retrieve_many(results_per_page, page_number)
      if page_number == 1
        limit(results_per_page)
      else
        limit(results_per_page).offset(results_per_page * (page_number - 1))
      end
    end

    def find_all(name)
      return [] if name.blank?

      where('name ILIKE ?', "%#{name}%")
        .order(:name)
    end
  end
end
