module ArticlePerformer
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def articles_price
      Helper.number_to_currency(9.99)
    end
  end

  def author_first_name
    author.split.first
  end

  def articles_link
    Helper.link_to 'Articles', Helper.routes.articles_path
  end

  def custom_helper_method
    Helper.custom_article_helper_method
  end
end
