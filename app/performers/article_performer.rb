module ArticlePerformer
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def articles_price
      number_to_currency(9.99)
    end
  end

  def author_first_name
    author.split.first
  end

  def articles_link
    link_to 'Articles', Rails.application.routes.url_helpers.articles_path
  end

  def custom_helper_method
    custom_article_helper_method
  end
end
