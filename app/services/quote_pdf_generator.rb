class QuotePdfGenerator
  FONT_PATH = Rails.root.join("app", "assets", "fonts", "NotoSansJP-Regular.ttf")
  FONT_BOLD_PATH = Rails.root.join("app", "assets", "fonts", "NotoSansJP-Bold.ttf")

  ITEM_TYPE_LABELS = {
    "conference_room" => "Conference Room",
    "accommodation" => "Accommodation",
    "breakfast" => "Breakfast",
    "lunch" => "Lunch",
    "dinner" => "Dinner"
  }.freeze

  def initialize(quote)
    @quote = quote
    @inquiry = quote.inquiry
    @facility = @inquiry.facility
  end

  def generate
    calculator = QuoteCalculator.new(@inquiry)
    result = calculator.calculate

    pdf = Prawn::Document.new(page_size: "A4")
    setup_fonts(pdf)

    render_header(pdf)
    render_company_info(pdf)
    render_inquiry_details(pdf)
    render_line_items(pdf, result)
    render_total(pdf, result)
    render_footer(pdf)

    pdf.render
  end

  private

  def setup_fonts(pdf)
    if FONT_PATH.exist?
      pdf.font_families.update(
        "NotoSansJP" => {
          normal: FONT_PATH.to_s,
          bold: FONT_BOLD_PATH.exist? ? FONT_BOLD_PATH.to_s : FONT_PATH.to_s
        }
      )
      pdf.font "NotoSansJP"
    end
  end

  def render_header(pdf)
    pdf.text "Quote", size: 24, style: :bold, align: :center
    pdf.move_down 10
    pdf.text "#{@facility.name}", size: 14, align: :center
    pdf.move_down 20
  end

  def render_company_info(pdf)
    pdf.text "To: #{@inquiry.company_name}", size: 12
    pdf.text "Attn: #{@inquiry.contact_name}", size: 12
    pdf.text "Date: #{Date.current}", size: 10
    pdf.move_down 15
  end

  def render_inquiry_details(pdf)
    pdf.text "Desired Date: #{@inquiry.desired_date}", size: 10
    pdf.text "Number of People: #{@inquiry.num_people}", size: 10
    pdf.move_down 15
  end

  def render_line_items(pdf, result)
    return if result.line_items.empty?

    table_data = [ [ "Item", "Day Type", "Unit Price", "Qty", "Subtotal" ] ]

    result.line_items.each do |item|
      table_data << [
        ITEM_TYPE_LABELS.fetch(item.item_type, item.item_type),
        item.day_type.titleize,
        format_currency(item.unit_price),
        item.quantity.to_s,
        format_currency(item.subtotal)
      ]
    end

    pdf.table(table_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "DDDDDD"
      columns(2..4).align = :right
    end
    pdf.move_down 10
  end

  def render_total(pdf, result)
    pdf.text "Total: #{format_currency(result.total)}", size: 16, style: :bold, align: :right
    pdf.move_down 20
  end

  def render_footer(pdf)
    if @facility.email_signature.present?
      pdf.text @facility.email_signature, size: 9, color: "666666"
    end
  end

  def format_currency(amount)
    "¥#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
