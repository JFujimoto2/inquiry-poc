module ApplicationHelper
  RESERVATION_STATUS_CLASSES = {
    Reservation::STATUS_PENDING_CONFIRMATION => "bg-yellow-100 text-yellow-800",
    Reservation::STATUS_CONFIRMED => "bg-green-100 text-green-800",
    Reservation::STATUS_CHECKED_IN => "bg-blue-100 text-blue-800",
    Reservation::STATUS_CHECKED_OUT => "bg-gray-100 text-gray-800",
    Reservation::STATUS_CANCELLED => "bg-red-100 text-red-800"
  }.freeze

  RESERVATION_STATUS_LABELS = {
    "pending_confirmation" => "確認待ち",
    "confirmed" => "確定",
    "checked_in" => "チェックイン済",
    "checked_out" => "チェックアウト済",
    "cancelled" => "キャンセル済"
  }.freeze

  CHANGE_REQUEST_STATUS_CLASSES = {
    ChangeRequest::STATUS_PENDING => "bg-yellow-100 text-yellow-800",
    ChangeRequest::STATUS_APPROVED => "bg-green-100 text-green-800",
    ChangeRequest::STATUS_REJECTED => "bg-red-100 text-red-800"
  }.freeze

  CHANGE_REQUEST_STATUS_LABELS = {
    "pending" => "対応待ち",
    "approved" => "承認済",
    "rejected" => "却下"
  }.freeze

  QUOTE_STATUS_LABELS = {
    "pending" => "処理中",
    "generated" => "生成済",
    "sent" => "送信済",
    "failed" => "失敗"
  }.freeze

  def reservation_status_class(status)
    RESERVATION_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end

  def reservation_status_label(status)
    RESERVATION_STATUS_LABELS.fetch(status, status)
  end

  def change_request_status_class(status)
    CHANGE_REQUEST_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end

  def change_request_status_label(status)
    CHANGE_REQUEST_STATUS_LABELS.fetch(status, status)
  end

  def quote_status_label(status)
    QUOTE_STATUS_LABELS.fetch(status, status)
  end
end
