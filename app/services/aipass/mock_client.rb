module Aipass
  class MockClient < Client
    MOCK_RESERVATION_PREFIX = "mock-res"
    MOCK_CUSTOMER_PREFIX = "mock-cust"
    MOCK_CLEANING_STATUS = "clean"
    MOCK_ROOMS_AVAILABLE = 10
    MOCK_TOTAL_REVENUE = 500_000
    MOCK_TOTAL_BOOKINGS = 25

    def sync_reservation(reservation)
      Response.new(
        success: true,
        data: { external_id: "#{MOCK_RESERVATION_PREFIX}-#{reservation.id}", synced_at: Time.current.iso8601 }
      )
    end

    def sync_customer(customer)
      Response.new(
        success: true,
        data: { external_id: "#{MOCK_CUSTOMER_PREFIX}-#{customer.id}", synced_at: Time.current.iso8601 }
      )
    end

    def fetch_cleaning_status(facility, date)
      Response.new(
        success: true,
        data: {
          facility_id: facility.id, date: date.to_s,
          status: MOCK_CLEANING_STATUS, rooms_available: MOCK_ROOMS_AVAILABLE
        }
      )
    end

    def fetch_sales_data(facility, date_range)
      Response.new(
        success: true,
        data: {
          facility_id: facility.id,
          period: { start: date_range.first.to_s, end: date_range.last.to_s },
          total_revenue: MOCK_TOTAL_REVENUE,
          total_bookings: MOCK_TOTAL_BOOKINGS
        }
      )
    end
  end
end
