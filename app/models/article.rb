class Article < ApplicationRecord
  include ArticlePerformer

  validates :name, presence: true
end
