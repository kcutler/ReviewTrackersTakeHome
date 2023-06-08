require "rails_helper"

RSpec.describe "ReviewService" do
  let(:subject) { ReviewService.new }
  let(:review_url) { "https://www.lendingtree.com/reviews/business/name-of-business/12345678" }
  let(:mortgage_url) { "https://www.lendingtree.com/reviews/mortgage/name-of-morgage/98765432" }
  let(:no_name_url)  { "https://www.lendingtree.com/reviews/business" }
  let(:other_url) { "https://anotherwebsite.com"}
  let(:faulty_url) { "https://badurl.com/articles\\/...." }
  let(:review_data) do
    [
      { title: "Review of a company", content: "Some content", author: "Author 11", rating: 4, date: DateTime.parse("January 2021") },
      { title: "My review", content: "Other content", author: "Author 22", rating: 2, date: DateTime.parse("November 2020") },
      { title: "Best company ever", content: "Additional content", author: "Author 44", rating: 5, date: DateTime.parse("July 1998") }
    ]
  end

  describe "#execute" do
    it "validates the URL is a Lending Tree business" do
      expect { subject.execute(review_url) }.not_to raise_error
    end

    it "raises an error when the URL is from Lending Tree and has no business name" do
      expect { subject.execute(no_name_url) }.to raise_error(StandardError, "URL #{no_name_url} is not a LendingTree Business Review")
    end

    it "raises an error when the URL is from another Lending Tree path" do
      expect { subject.execute(mortgage_url) }.to raise_error(StandardError, "URL #{mortgage_url} is not a LendingTree Business Review")
    end

    it "raises an error when the URL is from another website" do
      expect { subject.execute(other_url) }.to raise_error(StandardError, "URL #{other_url} is not a LendingTree Business Review")
    end

    it "raises an error when the URL format is invalid" do
      allow(URI).to receive(:parse).with(faulty_url).and_raise(URI::InvalidURIError)

      expect { subject.execute(faulty_url) }.to raise_error(StandardError, "URL #{faulty_url} is not valid")
    end

    context "when the URL is valid" do
      it "returns an array of review data" do
        allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).and_return(double(map: review_data))

        expect(subject.execute(review_url)).to eq(review_data)
      end

      it "raises an error when the URL cannot be opened" do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new("503", "Service Unavailable"))

        expect { subject.execute(review_url) }.to raise_error(StandardError, "Could not open URL due to 503")
      end

      it "raises a StandardError when error processing data" do
        allow(URI).to receive(:open)
        allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).and_raise(Nokogiri::SyntaxError)

        expect { subject.execute(review_url) }.to raise_error(StandardError, "Could not parse data")
      end
    end

    context "when a sort option is passed" do
      before do
        allow(URI).to receive(:open)
        allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).and_return(double(map: review_data))
      end

      it "sorts the review data by title " do
        sorted_by_title = [
          { title: "Best company ever", content: "Additional content", author: "Author 44", rating: 5, date: DateTime.parse("July 1998") },
          { title: "My review", content: "Other content", author: "Author 22", rating: 2, date: DateTime.parse("November 2020") },
          { title: "Review of a company", content: "Some content", author: "Author 11", rating: 4, date: DateTime.parse("January 2021") }
        ]

        expect(subject.execute(review_url, { sort: "title" })).to eq(sorted_by_title)
      end

      it "sorts the review data by rating" do
        sorted_by_rating = [
          { title: "My review", content: "Other content", author: "Author 22", rating: 2, date: DateTime.parse("November 2020") },
          { title: "Review of a company", content: "Some content", author: "Author 11", rating: 4, date: DateTime.parse("January 2021") },
          { title: "Best company ever", content: "Additional content", author: "Author 44", rating: 5, date: DateTime.parse("July 1998") }
        ]

        expect(subject.execute(review_url, { sort: "rating" })).to eq(sorted_by_rating)
      end

      it "sorts the review data by date" do
        sorted_by_date = [
          { title: "Best company ever", content: "Additional content", author: "Author 44", rating: 5, date: DateTime.parse("July 1998") },
          { title: "My review", content: "Other content", author: "Author 22", rating: 2, date: DateTime.parse("November 2020") },
          { title: "Review of a company", content: "Some content", author: "Author 11", rating: 4, date: DateTime.parse("January 2021") }
        ]

        expect(subject.execute(review_url, { sort: "date" })).to eq(sorted_by_date)
      end

      it "raises an error with an invalid sort field" do
        expect { subject.execute(review_url, { sort: "content" }) }.to raise_error(StandardError, "Invalid sort option: content")
      end
    end

    context "when a save option is passed" do
      before do
        allow(URI).to receive(:open)
        allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).and_return(double(map: review_data))
      end

      it "saves the review data to a file" do
        subject.execute(review_url, { save: true })

        expect(File.exist?("reviews.json")).to be(true)

        saved_data = File.read("reviews.json")

        expect(saved_data).to eq(JSON.pretty_generate(review_data))

        FileUtils.rm("reviews.json")
      end

      it "raises an error when it cannot save the review data" do
        allow(File).to receive(:open).and_raise(IOError)

        expect { subject.execute(review_url, { save: true }) }.to raise_error(StandardError, "Could not save review data to file due to IOError")
      end
    end
  end
end
