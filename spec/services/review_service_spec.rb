require 'rails_helper'

RSpec.describe 'ReviewService' do
	let(:subject) { ReviewService.new }
	let(:review_url) { "https://www.lendingtree.com/reviews/business/name-of-business/12345678" }
	let(:mortgage_url) { "https://www.lendingtree.com/reviews/mortgage/name-of-morgage/98765432" }
	let(:no_name_url)  { "https://www.lendingtree.com/reviews/business" }
	let(:other_url) { "https://anotherwebsite.com"}
	let(:faulty_url) { "https://badurl.com/articles\\/...." }

	it 'validates the URL is a Lending Tree business' do
		expect { subject.execute(review_url) }.not_to raise_error
	end

	it 'raises an error when the URL is from Lending Tree and has no business name' do
		expect { subject.execute(no_name_url) }.to raise_error(StandardError, "URL is not a LendingTree Business Review")
	end

	it 'raises an error when the URL is from another Lending Tree path' do
		expect { subject.execute(mortgage_url) }.to raise_error(StandardError, "URL is not a LendingTree Business Review")
	end

	it 'raises an error when the URL is from another website' do
		expect { subject.execute(other_url) }.to raise_error(StandardError, "URL is not a LendingTree Business Review")
	end

	it 'raises an error when the URL format is invalid' do
		allow(URI).to receive(:parse).with(faulty_url).and_raise(URI::InvalidURIError)

		expect { subject.execute(faulty_url) }.to raise_error(StandardError, "URL format is not valid")
	end
end