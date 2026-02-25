class EmailTemplate < ApplicationRecord
  belongs_to :facility

  validates :subject, presence: true
  validates :body, presence: true
  validates :facility_id, uniqueness: true
end
