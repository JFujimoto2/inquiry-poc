module ApplicationHelper
  RESERVATION_STATUS_CLASSES = {
    "pending_confirmation" => "bg-yellow-100 text-yellow-800",
    "confirmed" => "bg-green-100 text-green-800",
    "checked_in" => "bg-blue-100 text-blue-800",
    "checked_out" => "bg-gray-100 text-gray-800",
    "cancelled" => "bg-red-100 text-red-800"
  }.freeze

  def reservation_status_class(status)
    RESERVATION_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end
end
