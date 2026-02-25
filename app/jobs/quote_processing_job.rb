class QuoteProcessingJob < ApplicationJob
  queue_as :default

  def perform(quote_id)
    quote = Quote.find(quote_id)
    inquiry = quote.inquiry

    calculator = QuoteCalculator.new(inquiry)
    result = calculator.calculate
    inquiry.update!(total_amount: result.total)

    pdf_data = QuotePdfGenerator.new(quote).generate
    quote.update!(pdf_data: pdf_data, status: Quote::STATUS_GENERATED)

    QuoteMailer.send_quote(quote).deliver_now
    quote.update!(status: Quote::STATUS_SENT, sent_at: Time.current)
  rescue => e
    quote&.update(status: Quote::STATUS_FAILED)
    raise e
  end
end
