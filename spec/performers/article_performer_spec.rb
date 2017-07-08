require 'rails_helper'

RSpec.describe Article, type: :performer do
  let(:article) { FactoryGirl.create(:article) }

  describe 'Class Methods' do
    describe '.articles_price' do
      it 'returns articles price' do
        expect(Article.articles_price).to eq(number_to_currency(9.99))
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
        expect(article.articles_link).to eq(link_to 'Articles', articles_path)
      end
    end
  end
end