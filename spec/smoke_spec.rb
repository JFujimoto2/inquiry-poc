require "rails_helper"

RSpec.describe "Smoke test" do
  it "boots the Rails application" do
    expect(Rails.application).to be_a(Rails::Application)
  end
end
