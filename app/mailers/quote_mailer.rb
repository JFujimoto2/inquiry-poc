class QuoteMailer < ApplicationMailer
  def send_quote(quote)
    @quote = quote
    @inquiry = quote.inquiry
    @facility = @inquiry.facility
    template = @facility.email_templates.find_by!(template_type: "quote")

    subject = interpolate(template.subject)
    @body_text = interpolate(template.body)

    attachments["quote.pdf"] = {
      mime_type: "application/pdf",
      content: quote.pdf_data
    }

    mail(
      to: @inquiry.email,
      from: @facility.sender_email,
      subject: subject
    )
  end

  private

  def interpolate(text)
    data = {
      "facility_name" => @facility.name,
      "company_name" => @inquiry.company_name,
      "contact_name" => @inquiry.contact_name,
      "desired_date" => @inquiry.desired_date.to_s,
      "num_people" => @inquiry.num_people.to_s,
      "total_amount" => @inquiry.total_amount.to_s
    }
    text.gsub(/\{\{(\w+)\}\}/) { |_| data[$1] || "{{#{$1}}}" }
  end
end
