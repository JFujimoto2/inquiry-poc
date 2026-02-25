# コーディング規約

本プロジェクトで遵守するコーディング規約と確立されたパターンを定義する。

## 全般

### 基本原則

- **マジックナンバー・マジックストリングは禁止**。定数（`CONSTANT`）として定義する
- メソッドは単一責任。**1メソッド15行以内**を目安にする
- ネストは**最大3段階**。早期return（guard clause）を活用する
- 命名は意図を明確に。略語は避ける（`calc` → `calculate`, `btn` → `button`）
- コメントは「**なぜ（Why）**」のみ記述。「何を（What）」はコードで表現する

### Linter

- Rubyスタイルは `rubocop-rails-omakase` に準拠
- 文字列は**ダブルクォート**（`"`）を使用
- ハッシュはシンボルキー + Ruby 3.1のショートハンド記法を適宜使用

---

## Ruby / Rails

### モデル（`app/models/`）

#### 構成順序

1. 定数（`STATUSES`, `ROLES` など）
2. アソシエーション（`belongs_to`, `has_many` など）
3. バリデーション
4. スコープ
5. パブリックメソッド
6. プライベートメソッド

```ruby
class Reservation < ApplicationRecord
  # 1. 定数 — 必ず .freeze する
  STATUSES = %w[pending_confirmation confirmed checked_in checked_out cancelled].freeze

  # 2. アソシエーション — dependent を必ず指定
  belongs_to :inquiry
  belongs_to :customer
  belongs_to :facility
  has_many :change_requests, dependent: :destroy

  # 3. バリデーション — 定数を参照する
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :check_in_date, presence: true
  validates :num_people, presence: true, numericality: { greater_than: 0 }
  validate :check_out_after_check_in

  # 4. スコープ
  scope :active, -> { where.not(status: "cancelled") }
  scope :upcoming, -> { active.where("check_in_date >= ?", Date.current) }

  private

  # 5. カスタムバリデーション — guard clause で早期return
  def check_out_after_check_in
    return if check_in_date.blank? || check_out_date.blank?

    if check_out_date <= check_in_date
      errors.add(:check_out_date, "must be after check-in date")
    end
  end
end
```

#### ルール

- バリデーション値・ステータス値・区分値は**モデル内に定数として定義**する
  - 例: `ROLES = %w[staff admin].freeze`, `STATUSES = %w[pending approved rejected].freeze`
- アソシエーションには必ず `dependent:` を指定する（`:destroy`, `:nullify` 等）
- メールアドレスなどの正規化には `normalizes` を使用する
  ```ruby
  normalizes :email, with: ->(email) { email.strip.downcase }
  ```
- 真偽値のヘルパーメソッドは `?` 接尾辞で定義する
  ```ruby
  def admin?
    role == "admin"
  end
  ```
- **ビジネスロジックはモデルに書かない**。Service Objectに分離する

### Service Object（`app/services/`）

ビジネスロジックの格納先。1クラス1責任。

#### 基本構造

```ruby
class CreateReservationFromInquiry
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    ActiveRecord::Base.transaction do
      customer = find_or_create_customer
      link_customer_to_inquiry(customer)
      create_reservation(customer)
    end
  end

  private

  def find_or_create_customer
    Customer.find_or_create_by!(email: @inquiry.email) do |c|
      c.company_name = @inquiry.company_name
      c.contact_name = @inquiry.contact_name
    end
  end

  def link_customer_to_inquiry(customer)
    @inquiry.update!(customer:) unless @inquiry.customer_id
  end

  def create_reservation(customer)
    Reservation.create!(
      inquiry: @inquiry,
      customer:,
      facility: @inquiry.facility,
      status: "pending_confirmation",
      check_in_date: @inquiry.desired_date,
      num_people: @inquiry.num_people,
      total_amount: @inquiry.total_amount
    )
  end
end
```

#### ルール

- `initialize` でドメインオブジェクトを受け取る（プリミティブではなく）
- メインのエントリポイントは `call` メソッド（またはドメインに合った名前）
- カスタム例外はサービスクラス内にネストする
  ```ruby
  class ReservationStatusManager
    class InvalidTransitionError < StandardError; end
  end
  ```
- 複数ステップの処理は `ActiveRecord::Base.transaction` で囲む
- 不変の戻り値には `Struct.new(keyword_init: true)` を使用する
  ```ruby
  Result = Struct.new(:line_items, :total, keyword_init: true)
  ```
- ステートマシンの遷移は定数で定義する
  ```ruby
  VALID_TRANSITIONS = {
    "pending_confirmation" => %w[confirmed cancelled],
    "confirmed" => %w[checked_in cancelled],
  }.freeze
  ```

### コントローラ（`app/controllers/`）

#### 基本構造

```ruby
module Admin
  class ReservationsController < BaseController
    before_action :set_reservation, only: %i[show edit update destroy transition]

    def index
      @reservations = Reservation.includes(:facility, :customer).order(created_at: :desc)
      @reservations = @reservations.where(status: params[:status]) if params[:status].present?
    end

    def create
      @reservation = Reservation.new(reservation_params)
      if @reservation.save
        redirect_to admin_reservation_path(@reservation), notice: "Reservation was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!
      redirect_to admin_reservations_path, notice: "Reservation was successfully deleted.", status: :see_other
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:facility_id, :customer_id, :check_in_date, :num_people)
    end
  end
end
```

#### ルール

- RESTful CRUD アクションに従う
- `before_action :set_resource` で単一リソースをセットする（show, edit, update, destroy）
- **Strong Parameters を必ず使用する**（`params.require().permit()`）
- **N+1クエリを避ける**。`includes` / `preload` を適切に使用する
- HTTPステータスコード: バリデーションエラー → `:unprocessable_entity`、削除後 → `:see_other`
- サービスオブジェクトの例外は `rescue` でハンドリングする
  ```ruby
  def transition
    manager = ReservationStatusManager.new(@reservation)
    manager.transition_to!(params[:status])
    redirect_to admin_reservation_path(@reservation), notice: "Status updated."
  rescue ReservationStatusManager::InvalidTransitionError => e
    redirect_to admin_reservation_path(@reservation), alert: e.message
  end
  ```

### Concern（`app/controllers/concerns/`）

```ruby
module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    unless Current.session&.user&.admin?
      redirect_to root_path, alert: "Not authorized."
    end
  end
end
```

#### ルール

- `extend ActiveSupport::Concern` を必ず使用する
- `before_action` や `helper_method` の宣言は `included do` ブロック内に記述する
- メモ化には `||=` を使用する
  ```ruby
  def current_customer
    @current_customer ||= find_customer_from_session
  end
  ```
- 安全ナビゲーション演算子（`&.`）を活用する

### ジョブ（`app/jobs/`）

```ruby
class ReservationConfirmationJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    ReservationMailer.confirmation(reservation).deliver_now
  end
end
```

#### ルール

- `queue_as :default` でキュー名を指定する
- IDでレコードを取得し直す（リトライ時にフレッシュな状態を使う）
- 複数ステップの処理ではステータスを段階的に更新する
- エラーハンドリングで失敗ステータスを記録してから `raise` する
  ```ruby
  rescue => e
    quote&.update(status: "failed")
    raise e
  end
  ```

### メーラー（`app/mailers/`）

```ruby
class ReservationMailer < ApplicationMailer
  def confirmation(reservation)
    @reservation = reservation
    @customer = reservation.customer
    @facility = reservation.facility
    template = @facility.email_templates.find_by!(template_type: "reservation_confirmation")

    subject = interpolate(template.subject)
    @body_text = interpolate(template.body)

    mail(to: @customer.email, from: @facility.sender_email, subject:)
  end

  private

  def interpolate(text)
    data = {
      "facility_name" => @facility.name,
      "company_name" => @customer.company_name,
      "contact_name" => @customer.contact_name,
    }
    text.gsub(/\{\{(\w+)\}\}/) { |_| data[$1] || "{{#{$1}}}" }
  end
end
```

#### ルール

- テンプレート変数の形式: `{{variable_name}}`
- `interpolate` メソッドでテンプレート変数を展開する
- 未定義のプレースホルダーは元の文字列をそのまま残す

### ヘルパー（`app/helpers/`）

```ruby
module ApplicationHelper
  RESERVATION_STATUS_CLASSES = {
    "pending_confirmation" => "bg-yellow-100 text-yellow-800",
    "confirmed" => "bg-green-100 text-green-800",
  }.freeze

  def reservation_status_class(status)
    RESERVATION_STATUS_CLASSES.fetch(status, "bg-gray-100 text-gray-800")
  end
end
```

- 表示ロジックのマッピングは定数として定義し、ヘルパーメソッドで参照する

### ビュー（`app/views/`）

#### Tailwind CSS のパターン

```erb
<%# ページヘッダー %>
<div class="flex justify-between items-center mb-6">
  <h1 class="text-2xl font-bold">Reservations</h1>
</div>

<%# テーブル %>
<table class="w-full bg-white shadow rounded">
  <thead class="bg-gray-100">
    <tr>
      <th class="text-left p-3">Name</th>
    </tr>
  </thead>
  <tbody>
    <% @items.each do |item| %>
      <tr class="border-t">
        <td class="p-3"><%= item.name %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<%# フォーム %>
<%= form_with(model: [:admin, resource], class: "space-y-4") do |form| %>
  <% if resource.errors.any? %>
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
      <ul>
        <% resource.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :name, class: "block font-medium mb-1" %>
    <%= form.text_field :name, class: "w-full border rounded p-2" %>
  </div>

  <div>
    <%= form.submit class: "bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 cursor-pointer" %>
  </div>
<% end %>
```

#### ルール

- スタイリングは **Tailwind CSS ユーティリティクラス**を使用する
- フォームのフィールドスタイル: `class: "w-full border rounded p-2"`
- ボタンスタイル: `class: "bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 cursor-pointer"`
- リンクスタイル: `class: "text-blue-600 hover:underline"`
- ステータスバッジにはヘルパーメソッドでCSSクラスを取得する
- エラー表示は赤系（`bg-red-100 border-red-400 text-red-700`）で統一する
- フォームは `form_with` + `model: [:namespace, object]` で定義する

### ルーティング（`config/routes.rb`）

- 名前空間は `namespace` で定義する
- RESTful リソースを使用し、必要なアクションのみ `only:` で制限する
- カスタムアクションは `member` / `collection` ブロック内に定義する

```ruby
namespace :admin do
  root "dashboard#index"
  resources :reservations do
    member { patch :transition }
  end
  resources :inquiries, only: %i[index show]
end

namespace :mypage do
  root "dashboard#index"
  resources :reservations, only: %i[show] do
    resources :change_requests, only: %i[new create]
  end
end
```

---

## テスト

### 基本方針

- **TDDフロー**: Red → Green → Refactor
- テストフレームワーク: **RSpec + FactoryBot + Shoulda Matchers**
- E2E: Capybara + Playwright
- セキュリティ: Brakeman + bundler-audit
- テスト内のマジックナンバーも**定数化または `let` で意図を明確にする**

### テスト実行コマンド

```bash
bundle exec rspec                      # 全テスト
bundle exec brakeman --no-pager -q     # セキュリティスキャン
bundle exec bundler-audit check        # 依存脆弱性チェック
bundle exec rubocop                    # Lint
```

### Factory（`spec/factories/`）

```ruby
FactoryBot.define do
  factory :reservation do
    # アソシエーション（ファクトリ名で参照）
    inquiry
    customer
    facility

    # デフォルト値（ブロックで動的に評価）
    status { "pending_confirmation" }
    check_in_date { Date.new(2026, 4, 1) }
    check_out_date { Date.new(2026, 4, 2) }
    num_people { 10 }
    total_amount { 50_000 }

    # trait でバリエーションを定義
    trait :confirmed do
      status { "confirmed" }
      confirmed_at { Time.current }
    end

    trait :cancelled do
      status { "cancelled" }
      cancelled_at { Time.current }
    end
  end
end
```

#### ルール

- アソシエーションはファクトリ名で参照する
- リアルなテストデータには `Faker` を使用する
- ステータスのバリエーションは `trait` で定義する
- オプショナルなフィールドのデフォルトは `nil` にする

### モデルスペック（`spec/models/`）

```ruby
require "rails_helper"

RSpec.describe Reservation, type: :model do
  describe "validations" do
    subject { build(:reservation) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Reservation::STATUSES) }

    context "check_out_date validation" do
      it "is invalid when check_out_date is before check_in_date" do
        reservation = build(:reservation, check_in_date: Date.new(2026, 4, 2), check_out_date: Date.new(2026, 4, 1))
        expect(reservation).not_to be_valid
        expect(reservation.errors[:check_out_date]).to include("must be after check-in date")
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inquiry) }
    it { is_expected.to have_many(:change_requests).dependent(:destroy) }
  end

  describe "scopes" do
    let!(:active) { create(:reservation, :confirmed) }
    let!(:cancelled) { create(:reservation, :cancelled) }

    describe ".active" do
      it "excludes cancelled reservations" do
        expect(Reservation.active).to include(active)
        expect(Reservation.active).not_to include(cancelled)
      end
    end
  end
end
```

#### ルール

- Shoulda Matchers を基本バリデーション・アソシエーションのテストに使用する
- `subject { build(:model) }` で共有オブジェクトを定義する
- `context` で関連するテストを論理グループにまとめる
- テスト名は `"is invalid when..."`, `"is valid when..."` の形式にする
- バリデーションテストには `build`（DB保存しない）、スコープテストには `create` を使用する
- 永続化が必要なテストデータには `let!` を使用する

### リクエストスペック（`spec/requests/`）

```ruby
require "rails_helper"

RSpec.describe "Admin::Reservations", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }

  # 認可テストを最初に記述
  describe "authorization" do
    it "rejects staff users" do
      sign_in_as(staff)
      get admin_reservations_path
      expect(response).to redirect_to(root_path)
    end
  end

  context "as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/reservations" do
      it "renders the index page" do
        reservation = create(:reservation)
        get admin_reservations_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(reservation.facility.name)
      end
    end

    describe "POST /admin/reservations" do
      it "creates a reservation" do
        expect {
          post admin_reservations_path, params: { reservation: valid_params }
        }.to change(Reservation, :count).by(1)
      end
    end

    describe "DELETE /admin/reservations/:id" do
      it "deletes the reservation" do
        reservation = create(:reservation)
        expect {
          delete admin_reservation_path(reservation)
        }.to change(Reservation, :count).by(-1)
      end
    end
  end
end
```

#### ルール

- `describe` は `"HTTP_METHOD /path"` の形式で記述する
- 認可テストを CRUD テストの前に記述する
- `context "as [role]"` でロール別にグループ化し、`before { sign_in_as(user) }` でセットアップする
- HTTPステータスのアサーションには名前付きマッチャ（`:ok`, `:not_found`）を使用する
- データベースの副作用には `change(Model, :count)` を使用する
- 更新後のデータ確認には `.reload` を使用する
- ハッピーパス + エラーパス + 認可の3軸でテストする

### テストヘルパー（`spec/support/`）

```ruby
# spec/support/authentication_helpers.rb
module AuthenticationHelpers
  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
```

- 認証セットアップはヘルパーモジュールに分離する
- `RSpec.configure` で `type:` を指定してスペックタイプ別に include する

---

## Zeitwerk（オートロード）の注意点

- ファイル名とクラス/モジュール名は **Zeitwerk の命名規約**に従う
  - `app/services/aipass/client.rb` → `Aipass::Client`
  - `app/services/aipass/mock_client.rb` → `Aipass::MockClient`
- 1ファイルにつき1つの主要な定数を定義する
- 名前空間モジュールは `app/services/aipass.rb` で定義し、サブディレクトリ `app/services/aipass/` 以下に子クラスを配置する
- **CI環境では `eager_load = true` になる**ため、ローカルで通ってもCI で落ちる場合がある。命名規約違反に注意する
