# 管理者ユーザー
admin = User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "password123"
  u.role = "admin"
end
puts "管理者ユーザー: #{admin.email_address}"

# 施設
facilities_data = [
  { name: "高原ロッジ", sender_email: "info@kogen-lodge.example.com", sender_domain: "kogen-lodge.example.com", email_signature: "高原ロッジ\n〒390-0000 長野県松本市高原1-2-3\nTel: 0263-12-3456\nFax: 0263-12-3457" },
  { name: "海辺リゾート", sender_email: "info@umibe-resort.example.com", sender_domain: "umibe-resort.example.com", email_signature: "海辺リゾート\n〒413-0000 静岡県熱海市海岸4-5-6\nTel: 0557-65-4321\nFax: 0557-65-4322" }
]

facilities = facilities_data.map do |data|
  Facility.find_or_create_by!(name: data[:name]) do |f|
    f.sender_email = data[:sender_email]
    f.sender_domain = data[:sender_domain]
    f.email_signature = data[:email_signature]
  end
end
puts "施設: #{facilities.map(&:name).join('、')}"

# カレンダー種別（2026年ゴールデンウィーク）
golden_week_dates = (Date.new(2026, 4, 29)..Date.new(2026, 5, 6))
golden_week_dates.each do |date|
  CalendarType.find_or_create_by!(date: date) do |ct|
    ct.day_type = "holiday"
  end
end

# 休前日
CalendarType.find_or_create_by!(date: Date.new(2026, 4, 28)) do |ct|
  ct.day_type = "day_before_holiday"
end
puts "カレンダー種別: #{CalendarType.count}件"

# 料金マスタ — 全施設×全項目×全日種別
price_data = {
  "conference_room" => { "weekday" => 5_000, "holiday" => 7_000, "day_before_holiday" => 6_000 },
  "accommodation" => { "weekday" => 10_000, "holiday" => 15_000, "day_before_holiday" => 12_000 },
  "breakfast" => { "weekday" => 1_000, "holiday" => 1_200, "day_before_holiday" => 1_100 },
  "lunch" => { "weekday" => 1_500, "holiday" => 1_800, "day_before_holiday" => 1_600 },
  "dinner" => { "weekday" => 3_000, "holiday" => 3_500, "day_before_holiday" => 3_200 }
}

facilities.each do |facility|
  price_data.each do |item_type, day_prices|
    day_prices.each do |day_type, price|
      PriceMaster.find_or_create_by!(facility: facility, item_type: item_type, day_type: day_type) do |pm|
        pm.unit_price = price
      end
    end
  end
end
puts "料金マスタ: #{PriceMaster.count}件"

# メールテンプレート
facilities.each do |facility|
  EmailTemplate.find_or_create_by!(facility: facility, template_type: "quote") do |et|
    et.subject = "【#{facility.name}】{{company_name}}様 お見積りのご案内"
    et.body = <<~BODY
      {{contact_name}} 様

      この度は#{facility.name}へお問い合わせいただき、誠にありがとうございます。
      ご依頼いただきました内容にてお見積りを作成いたしましたので、添付ファイルをご確認ください。

      ■ ご利用日程: {{desired_date}} 〜 {{desired_end_date}}
      ■ ご利用人数: {{num_people}}名
      ■ お見積り金額: ¥{{total_amount}}

      ご不明な点がございましたら、お気軽にお問い合わせください。

      #{facility.email_signature}
    BODY
  end

  EmailTemplate.find_or_create_by!(facility: facility, template_type: "reservation_confirmation") do |et|
    et.subject = "【#{facility.name}】{{company_name}}様 ご予約確定のお知らせ"
    et.body = <<~BODY
      {{contact_name}} 様

      #{facility.name}をご利用いただきありがとうございます。
      下記の内容でご予約が確定いたしましたのでお知らせいたします。

      ■ チェックイン: {{check_in_date}}
      ■ ご利用人数: {{num_people}}名
      ■ 合計金額: ¥{{total_amount}}

      当日のお越しをお待ちしております。

      #{facility.email_signature}
    BODY
  end
end
puts "メールテンプレート: #{EmailTemplate.count}件"
puts "シード完了！"
