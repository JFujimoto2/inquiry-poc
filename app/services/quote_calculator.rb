class QuoteCalculator
  class PriceNotFoundError < StandardError; end

  LineItem = Struct.new(:date, :item_type, :day_type, :unit_price, :quantity, :subtotal, keyword_init: true)
  Result = Struct.new(:line_items, :total, keyword_init: true)

  ITEM_FIELDS = {
    "conference_room" => :conference_room?,
    "accommodation" => :accommodation?,
    "breakfast" => :breakfast?,
    "lunch" => :lunch?,
    "dinner" => :dinner?
  }.freeze

  def initialize(inquiry)
    @inquiry = inquiry
    @facility = inquiry.facility
  end

  def calculate
    dates = @inquiry.date_range.to_a
    day_types = batch_day_types(dates)
    line_items = []

    dates.each do |date|
      day_type = day_types[date]

      ITEM_FIELDS.each do |item_type, method|
        next unless @inquiry.public_send(method)

        unit_price = fetch_price(item_type, day_type)
        subtotal = unit_price * @inquiry.num_people

        line_items << LineItem.new(
          date: date,
          item_type: item_type,
          day_type: day_type,
          unit_price: unit_price,
          quantity: @inquiry.num_people,
          subtotal: subtotal
        )
      end
    end

    total = line_items.sum(&:subtotal)
    Result.new(line_items: line_items, total: total)
  end

  private

  def batch_day_types(dates)
    registered = CalendarType.where(date: dates).pluck(:date, :day_type).to_h
    dates.index_with { |date| registered[date] || "weekday" }
  end

  def fetch_price(item_type, day_type)
    PriceMaster.price_for(@facility, item_type, day_type)
  rescue ActiveRecord::RecordNotFound
    raise PriceNotFoundError,
      "Price not found for facility=#{@facility.name}, item=#{item_type}, day=#{day_type}"
  end
end
