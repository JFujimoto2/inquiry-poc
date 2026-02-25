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

  HEADER_TITLE = "Quote"
  TITLE_FONT_SIZE = 24
  SUBTITLE_FONT_SIZE = 16
  SUBHEADER_FONT_SIZE = 14
  BODY_FONT_SIZE = 12
  DETAIL_FONT_SIZE = 10
  FOOTER_FONT_SIZE = 9
  SPACING_LARGE = 20
  SPACING_MEDIUM = 15
  SPACING_SMALL = 10
  TABLE_HEADER_BG_COLOR = "DDDDDD"
  FOOTER_TEXT_COLOR = "666666"

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
    pdf.text HEADER_TITLE, size: TITLE_FONT_SIZE, style: :bold, align: :center
    pdf.move_down SPACING_SMALL
    pdf.text @facility.name.to_s, size: SUBHEADER_FONT_SIZE, align: :center
    pdf.move_down SPACING_LARGE
  end

  def render_company_info(pdf)
    pdf.text "To: #{@inquiry.company_name}", size: BODY_FONT_SIZE
    pdf.text "Attn: #{@inquiry.contact_name}", size: BODY_FONT_SIZE
    pdf.text "Date: #{Date.current}", size: DETAIL_FONT_SIZE
    pdf.move_down SPACING_MEDIUM
  end

  def render_inquiry_details(pdf)
    pdf.text "Desired Date: #{@inquiry.desired_date}", size: DETAIL_FONT_SIZE
    pdf.text "Number of People: #{@inquiry.num_people}", size: DETAIL_FONT_SIZE
    pdf.move_down SPACING_MEDIUM
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
      row(0).background_color = TABLE_HEADER_BG_COLOR
      columns(2..4).align = :right
    end
    pdf.move_down SPACING_SMALL
  end

  def render_total(pdf, result)
    pdf.text "Total: #{format_currency(result.total)}", size: SUBTITLE_FONT_SIZE, style: :bold, align: :right
    pdf.move_down SPACING_LARGE
  end

  def render_footer(pdf)
    if @facility.email_signature.present?
      pdf.text @facility.email_signature, size: FOOTER_FONT_SIZE, color: FOOTER_TEXT_COLOR
    end
  end

  def format_currency(amount)
    "¥#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
