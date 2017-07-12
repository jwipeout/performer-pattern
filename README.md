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

The __Rails Helpers__ are not automatically included in modules. Most likely you will need the helpers at some point since performers are used for view methods. To include all the helpers in any performer that is created we will add this to an initializer. 

This allows you to use all the helpers in performer instance or class methods. _BE AWARE_ that this brings in a lot of methods that could potentially clash with your performer methods. 

```ruby
# config/initializers/performers.rb

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
```

### RSpec

If you are using __Rspec__ you can also include the rails helpers into performer specs. Add this file to your spec/support, then require it in your rails_helper.rb

```ruby
# spec/support/performers.rb

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
```

```ruby
# spec/rails_helper.rb

require 'support/performers'
```

### Rails Test Unit

If you are using __Rails Test Unit__ you can include helpers into each performer test.

```ruby
require 'test_helper'

class ArticlePerformerTest < ActiveSupport::TestCase
  include ActionView::Helpers
  include ArticlesHelper
  include Rails.application.routes.url_helpers

  setup do
    @article = articles(:one)
  end

  test '.articles_price' do
    assert_equal(Article.articles_price, number_to_currency(9.99))
  end

  test "#articles_link" do
    assert_equal(@article.articles_link, (link_to 'Articles', articles_path))
  end
end
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

### Route helpers

If you plan on using route helpers in your Performer you must access it like this ```Rails.application.routes.url_helpers.articles_path```. There is a problem with including the url_helpers module into the Performer module currently.

# Contributing

Every decision made comes with ups and downs. People have different preferences and that is what makes our communtity great.

Improving the code is always welcomed! Send a pull request.

I am speficially looking for a solution to the include of the ```Rails.application.routes.url_helpers``` module into our Performer module.

If you find this pattern useful spread the word or write a blog post about it.

Cheers,<br>
[jwipeout](https://github.com/jwipeout)
