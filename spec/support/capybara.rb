require "capybara/rspec"

# Use Playwright for system specs if available, otherwise fall back to rack_test
begin
  require "capybara/playwright"

  Capybara.register_driver :playwright do |app|
    Capybara::Playwright::Driver.new(app,
      browser_type: :chromium,
      headless: true
    )
  end

  Capybara.default_driver = :rack_test
  Capybara.javascript_driver = :playwright
rescue LoadError
  # Playwright not available, use rack_test only
  Capybara.default_driver = :rack_test
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :playwright
  end
end
