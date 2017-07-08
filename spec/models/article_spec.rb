require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article) { FactoryGirl.create(:article) }

  describe 'Validations' do
    describe 'presence of name' do
      context 'name present' do
        it 'is valid' do
          expect(article).to be_valid
        end
      end

      context 'name not present' do
        it 'is not valid' do
          article.name = nil
          expect(article).to_not be_valid
        end
      end
    end
  end
end
