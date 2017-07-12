RSpec.configure do |config|
  # Adding helper modules to peformers
  performer_modules = [
    ActionView::Helpers,
    Rails.application.routes.url_helpers
  ]

  Dir.glob("#{Rails.root}/app/helpers/*.rb") do |helper_file|
    custom_helper = helper_file.split('/').last.split('.').first.classify.constantize
    performer_modules << custom_helper
  end

  performer_modules.each { |rails_module| config.include rails_module, type: :performer }
end
