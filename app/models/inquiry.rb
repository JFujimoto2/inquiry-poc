class Inquiry < ApplicationRecord
  belongs_to :facility
  belongs_to :customer, optional: true
  has_one :quote, dependent: :destroy
  has_one :reservation, dependent: :destroy

  validates :desired_date, presence: true
  validates :desired_end_date, presence: true
  validates :num_people, presence: true, numericality: { greater_than: 0 }
  validates :company_name, presence: true
  validates :contact_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :breakfast_requires_accommodation
  validate :end_date_after_start_date

  def date_range
    desired_date..desired_end_date
  end

  def num_nights
    (desired_end_date - desired_date).to_i
  end

  private

  def breakfast_requires_accommodation
    if breakfast? && !accommodation?
      errors.add(:breakfast, "は宿泊を選択した場合のみ利用できます")
    end
  end

  def end_date_after_start_date
    return if desired_date.blank? || desired_end_date.blank?

    if desired_end_date < desired_date
      errors.add(:desired_end_date, "は利用開始日以降の日付を指定してください")
    end
  end
end
