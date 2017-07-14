class Helper
  extend ActionView::Helpers::UrlHelper
  extend ActionView::Helpers::TagHelper

  class << self
    def render(**args)
      ApplicationController.render(args)
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end

  class LoadCustomHelpers
    class << self
      def load_custom_helpers
        Dir.glob("#{Rails.root}/app/helpers/*.rb") do |helper_file|
          custom_helper = helper_file.split('/').last.split('.').first.classify.constantize
          Helper.extend custom_helper
        end
      end
    end

    load_custom_helpers
  end
end
