class QuoteProcessingJob < ApplicationJob
  queue_as :default

  def perform(quote_id)
    quote = Quote.find(quote_id)
    inquiry = quote.inquiry

    calculator = QuoteCalculator.new(inquiry)
    result = calculator.calculate
    inquiry.update!(total_amount: result.total)

    pdf_data = QuotePdfGenerator.new(quote).generate
    quote.update!(pdf_data: pdf_data, status: "generated")

    QuoteMailer.send_quote(quote).deliver_now
    quote.update!(status: "sent", sent_at: Time.current)
  rescue => e
    quote&.update(status: "failed")
    raise e
  end
end
