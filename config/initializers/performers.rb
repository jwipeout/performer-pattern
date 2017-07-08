Dir.glob("#{Rails.root}/app/performers/*.rb") do |file|
  performer_module_name = file.split('/').last.split('.').first.classify.constantize

  performer_module_name.include ActionView::Helpers
  performer_module_name::ClassMethods.include ActionView::Helpers
end
