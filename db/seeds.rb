# Admin user
admin = User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "password123"
  u.role = "admin"
end
puts "Admin user: #{admin.email_address}"

# Facilities
facilities_data = [
  { name: "Mountain Lodge", sender_email: "info@mountain-lodge.example.com", sender_domain: "mountain-lodge.example.com", email_signature: "Mountain Lodge\nTel: 03-1234-5678" },
  { name: "Seaside Resort", sender_email: "info@seaside-resort.example.com", sender_domain: "seaside-resort.example.com", email_signature: "Seaside Resort\nTel: 03-8765-4321" }
]

facilities = facilities_data.map do |data|
  Facility.find_or_create_by!(name: data[:name]) do |f|
    f.sender_email = data[:sender_email]
    f.sender_domain = data[:sender_domain]
    f.email_signature = data[:email_signature]
  end
end
puts "Facilities: #{facilities.map(&:name).join(', ')}"

# Calendar types (holidays for Golden Week 2026)
golden_week_dates = (Date.new(2026, 4, 29)..Date.new(2026, 5, 6))
golden_week_dates.each do |date|
  CalendarType.find_or_create_by!(date: date) do |ct|
    ct.day_type = "holiday"
  end
end

# Day before holiday
CalendarType.find_or_create_by!(date: Date.new(2026, 4, 28)) do |ct|
  ct.day_type = "day_before_holiday"
end
puts "Calendar types: #{CalendarType.count} entries"

# Price masters - all combinations for both facilities
price_data = {
  "conference_room" => { "weekday" => 5_000, "holiday" => 7_000, "day_before_holiday" => 6_000 },
  "accommodation" => { "weekday" => 10_000, "holiday" => 15_000, "day_before_holiday" => 12_000 },
  "breakfast" => { "weekday" => 1_000, "holiday" => 1_200, "day_before_holiday" => 1_100 },
  "lunch" => { "weekday" => 1_500, "holiday" => 1_800, "day_before_holiday" => 1_600 },
  "dinner" => { "weekday" => 3_000, "holiday" => 3_500, "day_before_holiday" => 3_200 }
}

facilities.each do |facility|
  price_data.each do |item_type, day_prices|
    day_prices.each do |day_type, price|
      PriceMaster.find_or_create_by!(facility: facility, item_type: item_type, day_type: day_type) do |pm|
        pm.unit_price = price
      end
    end
  end
end
puts "Price masters: #{PriceMaster.count} entries"

# Email templates
facilities.each do |facility|
  EmailTemplate.find_or_create_by!(facility: facility, template_type: "quote") do |et|
    et.subject = "Quote for {{company_name}} - {{facility_name}}"
    et.body = <<~BODY
      Dear {{contact_name}},

      Thank you for your inquiry at {{facility_name}}.
      Please find your quote attached for {{num_people}} people on {{desired_date}}.

      Total: ¥{{total_amount}}

      If you have any questions, please don't hesitate to contact us.

      Best regards,
      #{facility.name} Staff
    BODY
  end

  EmailTemplate.find_or_create_by!(facility: facility, template_type: "reservation_confirmation") do |et|
    et.subject = "Reservation Confirmed - {{facility_name}}"
    et.body = <<~BODY
      Dear {{contact_name}},

      Your reservation at {{facility_name}} has been confirmed.

      Check-in: {{check_in_date}}
      Number of guests: {{num_people}}
      Total: ¥{{total_amount}}

      We look forward to welcoming you.

      Best regards,
      #{facility.name} Staff
    BODY
  end
end
puts "Email templates: #{EmailTemplate.count} entries"
puts "Seed complete!"
