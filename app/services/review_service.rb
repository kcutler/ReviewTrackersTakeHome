require 'uri/http'

class ReviewService
	def execute(url)
		parsed_url = parse_url(url)
		validate_lending_tree_url(parsed_url)
	end

	def parse_url(url)
		URI.parse(url)

	rescue URI::InvalidURIError
		raise StandardError, "URL format is not valid"
	end

	def validate_lending_tree_url(parsed_url)
		valid_host = "www.lendingtree.com"
		valid_path = %r{^/reviews/business/[A-Za-z-]+/\d+}

		unless parsed_url && valid_host.include?(parsed_url.host) && parsed_url.path =~ valid_path
			raise StandardError, "URL is not a LendingTree Business Review" 
		end
	end
end
