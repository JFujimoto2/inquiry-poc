class User < ApplicationRecord
  STAFF_ROLE = "staff"
  ADMIN_ROLE = "admin"
  ROLES = [ STAFF_ROLE, ADMIN_ROLE ].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == ADMIN_ROLE
  end

  def staff?
    role == STAFF_ROLE
  end
end
