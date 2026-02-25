module Aipass
  class MockClient < Client
    def sync_reservation(reservation)
      Response.new(
        success: true,
        data: { external_id: "mock-res-#{reservation.id}", synced_at: Time.current.iso8601 }
      )
    end

    def sync_customer(customer)
      Response.new(
        success: true,
        data: { external_id: "mock-cust-#{customer.id}", synced_at: Time.current.iso8601 }
      )
    end

    def fetch_cleaning_status(facility, date)
      Response.new(
        success: true,
        data: { facility_id: facility.id, date: date.to_s, status: "clean", rooms_available: 10 }
      )
    end

    def fetch_sales_data(facility, date_range)
      Response.new(
        success: true,
        data: {
          facility_id: facility.id,
          period: { start: date_range.first.to_s, end: date_range.last.to_s },
          total_revenue: 500_000,
          total_bookings: 25
        }
      )
    end
  end
end
