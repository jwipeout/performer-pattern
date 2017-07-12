def constanize_file_name(file)
  file.split('/').last.split('.').first.classify.constantize
end

def include_modules(performer_module_constant, module_to_include)
  performer_module_constant.include module_to_include
  performer_module_constant::ClassMethods.include module_to_include
end

Dir.glob("#{Rails.root}/app/performers/*.rb") do |performer_file|
  performer_module_name = constanize_file_name(performer_file)
  include_modules(performer_module_name, ActionView::Helpers)

  Dir.glob("#{Rails.root}/app/helpers/*.rb") do |helper_file|
    custom_helper = constanize_file_name(helper_file)
    include_modules(performer_module_name, custom_helper)
  end
end
