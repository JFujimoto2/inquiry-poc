module Aipass
  class Client
    def sync_reservation(reservation)
      raise NotImplementedError, "#{self.class}#sync_reservation is not yet implemented"
    end

    def sync_customer(customer)
      raise NotImplementedError, "#{self.class}#sync_customer is not yet implemented"
    end

    def fetch_cleaning_status(facility, date)
      raise NotImplementedError, "#{self.class}#fetch_cleaning_status is not yet implemented"
    end

    def fetch_sales_data(facility, date_range)
      raise NotImplementedError, "#{self.class}#fetch_sales_data is not yet implemented"
    end
  end
end
