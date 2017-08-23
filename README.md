# Performer Pattern: Rails Presentation Logic

The performer pattern creates seperation for the methods in your model that are view related. The performers are modules and are included into the corresponding model. This is meant to be a practical approach that adds minimal complexity, while gaining organization and flexibility.

## Benefits To Performers?

If you are familiar with __Helpers__, you might have noticed that adding too many methods starts to pollute the global namespace. With __Performers__ you create a corresponding ```ArticlePerformer``` module and include it into the model ```Article```.

```ruby
# app/models/article.rb

class Article < ApplicationRecord
  include ArticlePerformer
end
```

There are other patterns to help the fat model problem like the __Decorator Pattern__ and __Presenter Pattern__, but come with their set of _trade-offs_. By changing model objects to be decorated, we add another level of unwanted complexity. Occasionally there are conflicts with other patterns like the __Delegator Pattern__.

Also you will notice that your app starts to have all this decoration or presenting all over the place and you have to keep track if it is necessary to do so.

```ruby
# app/controllers/articles_controller.rb

# Decorator Pattern: Draper Gem
def index
  @articles = ArticleDecorator.decorate_collection(Article.all)
end

# Presenter Pattern
def index
  @articles = Article.all.collect { |article| ArticlePresenter.new(article) }
end

# Performer Pattern
def index
  @articles = Article.all
end
```

## Installation

The example app uses this setup and is a great resource to reference.

- Ruby 2.3.3
- Rails 5.0.1

Performers go in a new directory in ```app/performers```. You must create this directory and add any performers that you intend to use in there. 

The __Rails Helpers__ are not automatically included in modules. Most likely you will need the helpers at some point since performers are used for view methods. Including these modules into the performer modules is a  big pain. The pain continues when you end up having to include the same modules into your tests as well. 

Creating a central class where helper methods can live seemed like a nice solution. No more including modules all over the place. Include the helper modules you would like to use by extending the Helper class. This allows you to access them as class methods. Also we don't have to worry about naming collisions because they are scoped under the Helper class name.

You then can access the helper method like this

```ruby
Helper.number_to_currency(9.99)
```

Use the [Rails Anywhere Helper Gem](https://github.com/jwipeout/rails-helper-anywhere) or add this file to the directory app/support.

```ruby
# app/support/helper.rb

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
```

### RSpec

If you are using __Rspec__ you can access the helpers the same way that you do with your performer module. 

```ruby
# spec/performers/article_performer_spec.rb

require 'rails_helper'

RSpec.describe Article, type: :performer do
  let(:article) { FactoryGirl.create(:article) }

  describe 'Class Methods' do
    describe '.articles_price' do
      it 'returns articles price' do
        expect(Article.articles_price).to eq(Helper.number_to_currency(9.99))
      end
    end
  end

  describe 'Instance Methods' do
    describe '#author_first_name' do
      it 'returns authors first name' do
        expect(article.author_first_name).to eq(article.author.split.first)
      end
    end

    describe '#articles_link' do
      it 'returns articles html link' do
        expect(article.articles_link).to eq(Helper.link_to 'Articles', Helper.routes.articles_path)
      end
    end

    describe '#custom_helper_method' do
      it 'returns custom articles helper method' do
        expect(article.custom_helper_method).to eq(Helper.custom_article_helper_method)
      end
    end
  end
end
```

```ruby
# spec/rails_helper.rb

require 'support/performers'
```

## Create Performers

Create __Performers__ and add them to your ```app/peformers``` directory. Name the file with underscores starting with the model name and ending with performer.

```ruby
# app/performers/article_performer.rb

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
```

Then include it into your model.


```ruby
# app/models/article.rb

class Article < ApplicationRecord
  include ArticlePerformer
end
```

Notice that you can add __Class and Instance Methods__ in the performer. Instance methods are placed inside of the class. Class Methods go inside the module called ```ClassMethods```.

If you plan on using class methods, don't forget to add the  ```self.included``` hook that extends the class that the module gets included into.

# Contributing

Every decision made comes with ups and downs. People have different preferences and that is what makes our communtity great.

Improving the code is always welcomed! Send a pull request.

If you find this pattern useful spread the word or write a blog post about it.

Cheers,<br>
[jwipeout](https://github.com/jwipeout)
