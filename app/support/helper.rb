class Helper
  Dir.glob("#{Rails.root}/app/helpers/*.rb") do |helper_file|
    extend helper_file.split('/').last.split('.').first.classify.constantize
  end

  @routes = Rails.application.routes.url_helpers
  @action_view = ActionView::Base.new('app/views')

  class << self
    attr_reader :routes, :action_view

    def method_missing(method, *args, &block)
      if routes.respond_to?(method)
        routes.send(method, *args, &block)
      elsif action_view.respond_to?(method)
        action_view.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      routes.respond_to?(method, include_private) ||
        action_view.respond_to?(method, include_private) ||
        super
    end
  end
end
