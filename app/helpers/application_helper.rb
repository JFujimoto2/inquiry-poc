module ApplicationHelper
  RESERVATION_STATUS_CLASSES = {
    Reservation::STATUS_PENDING_CONFIRMATION => "bg-yellow-100 text-yellow-800",
    Reservation::STATUS_CONFIRMED => "bg-green-100 text-green-800",
    Reservation::STATUS_CHECKED_IN => "bg-blue-100 text-blue-800",
    Reservation::STATUS_CHECKED_OUT => "bg-gray-100 text-gray-800",
    Reservation::STATUS_CANCELLED => "bg-red-100 text-red-800"
  }.freeze

  def reservation_status_class(status)
    RESERVATION_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end

  CHANGE_REQUEST_STATUS_CLASSES = {
    ChangeRequest::STATUS_PENDING => "bg-yellow-100 text-yellow-800",
    ChangeRequest::STATUS_APPROVED => "bg-green-100 text-green-800",
    ChangeRequest::STATUS_REJECTED => "bg-red-100 text-red-800"
  }.freeze

  def change_request_status_class(status)
    CHANGE_REQUEST_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end
end
