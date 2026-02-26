class InquiriesController < ApplicationController
  allow_unauthenticated_access

  def new
    @inquiry = Inquiry.new(dev_defaults)
    @facilities = Facility.order(:name)
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    unless @inquiry.valid?
      @facilities = Facility.order(:name)
      return render :new, status: :unprocessable_entity
    end

    calculator = QuoteCalculator.new(@inquiry)
    result = calculator.calculate
    @inquiry.total_amount = result.total

    if @inquiry.save
      quote = @inquiry.create_quote!(status: "pending")
      QuoteProcessingJob.perform_later(quote.id)
      redirect_to thank_you_inquiries_path
    else
      @facilities = Facility.order(:name)
      render :new, status: :unprocessable_entity
    end
  rescue QuoteCalculator::PriceNotFoundError
    @inquiry.errors.add(:base, "料金設定が不完全です。お手数ですがお問い合わせください。")
    @facilities = Facility.order(:name)
    render :new, status: :unprocessable_entity
  end

  def thank_you; end

  private

  def dev_defaults
    return {} unless Rails.env.development?

    {
      facility_id: Facility.first&.id,
      desired_date: 1.week.from_now.to_date,
      desired_end_date: (1.week.from_now + 1.day).to_date,
      num_people: 10,
      conference_room: true,
      lunch: true,
      company_name: "テスト株式会社",
      contact_name: "山田 太郎",
      email: "yamada@example.com"
    }
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :facility_id, :desired_date, :desired_end_date, :num_people,
      :conference_room, :accommodation, :breakfast, :lunch, :dinner,
      :company_name, :contact_name, :email
    )
  end
end
