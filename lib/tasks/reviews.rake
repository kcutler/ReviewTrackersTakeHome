require_relative '../../app/services/review_service'

namespace :reviews do
  desc "Calls review service to get review data for a given link"
  
  task :get_lendingtree_reviews, [:link, :sort, :save] do |t, args|
    unless args[:link]
      puts "Please include a link"
      exit
    end

    options = {}

    options[:sort] = args[:sort] if args[:sort]
    options[:save] = true if args[:save]

    if options.empty?
      reviews = ReviewService.new.execute(args[:link])
    else
      reviews = ReviewService.new.execute(args[:link], options)
    end

    puts "Found the following reviews: #{JSON.pretty_generate(reviews)}"
  end
end
