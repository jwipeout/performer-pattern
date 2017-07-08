require 'test_helper'

class ArticlePerformerTest < ActiveSupport::TestCase
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  setup do
    @article = articles(:one)
  end

  test '.articles_price' do
    assert_equal(Article.articles_price, number_to_currency(9.99))
  end

  test '#author_first_name' do
    assert_equal(@article.author_first_name, @article.author.split.first)
  end

  test "#articles_link" do
    assert_equal(@article.articles_link, (link_to 'Articles', articles_path))
  end
end
