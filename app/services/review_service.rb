require "uri/http"
require "nokogiri"
require "open-uri"
require "json"

class ReviewService
  def execute(url, options = {})
    parsed_url = parse_url(url)
    validate_lending_tree_url(parsed_url)
    review_data = extract_review_data(parsed_url)

    sort_review_data(review_data, options[:sort]) if options.has_key?(:sort)
    save_review_data(review_data) if options.has_key?(:save)

    review_data
  end

  private

  def extract_review_data(parsed_url)
    html = Nokogiri::HTML(URI.open(parsed_url))

    html.css(".mainReviews").map do |review|
      {
        title: review.css(".reviewTitle").text.strip,
        content: review.css(".reviewText").text.strip,
        author: review.css(".consumerName").text.split(" ")[0],
        rating: review.css(".numRec").text.split(" ")[0][1].to_i,
        date: DateTime.parse(review.css(".consumerReviewDate").text.split(" ")[-2..-1].join(" "))
      }
    end

  rescue OpenURI::HTTPError => e
    raise StandardError, "Could not open URL due to #{e.message}"
  rescue Nokogiri::SyntaxError
    raise StandardError, "Could not parse data"
  end

  def parse_url(url)
    URI.parse(url)

  rescue URI::InvalidURIError
    raise StandardError, "URL #{url} is not valid"
  end

  def validate_lending_tree_url(parsed_url)
    valid_host = "www.lendingtree.com"
    valid_path = %r{^/reviews/business/[A-Za-z-]+/\d+}

    unless parsed_url && valid_host.include?(parsed_url.host) && parsed_url.path =~ valid_path
      raise StandardError, "URL #{parsed_url} is not a LendingTree Business Review" 
    end
  end

  def save_review_data(review_data)
    File.open("reviews.json", "w") do |file|
      file.write(JSON.pretty_generate(review_data))
    end

  rescue IOError => e
    raise StandardError, "Could not save review data to file due to #{e.message}"
  end

  def sort_review_data(review_data, field)
    acceptable_fields = ["title", "author", "rating", "date"]

    raise StandardError, "Invalid sort option: #{field}" unless acceptable_fields.include?(field)

    review_data.sort_by! { |review| review[field.to_sym] }
  end
end
