# README
Solution to backend code challenge for Review Trackers written in Ruby. 

### Dependencies
* Ruby 2.7.2
* Rails 7.0.4.3

### Setup
* Prerequisites: **Ruby** and **Rails** on your machine 
* Clone the repository with preferred method:
  * https: `git clone https://github.com/kcutler/ReviewTrackersTakeHome.git` 
  * ssh: `git clone git@github.com:kcutler/ReviewTrackersTakeHome.git`
* Install dependencies: `bundle install` 

### How to run the test suite
The application uses Rspec for testing. 
* `bundle exec rspec spec/services/review_service_spec.rb`

### Implementation overview
For the assignment, I took a very simple approach by creating a standalone service. The service has an execute method with one required argument and an optional hash. The required argument is a URL and the optional arguments are for sorting or saving the response. 

The service has multiple responsibilities:
* Parsing the link
* Validating the link is from a lending tree business site
* Reading and parsing the reviews from the lending tree business site
* Returning the review data
* Optional: sorting the review data by title, date, rating, author
* Optional: saving the review data to a json file

**Error handling:** The service rescues errors in different parts of the service. When the error is rescued, a standard error is raised with a helpful message. 

**Considerations:** I considered setting up a controller and route, however, since there was no need for a datastore or a view, I did not create a route and controller method. While the Model View Controller (MVC) framework of Rails is helpful, it did not seem necessary in this context. 

### Assumptions
* The service works exclusively with URLs from Lending Tree Businesses
* The service only reads reviews from the first page of the URL

### Future work
* Save file with name of company
* Sort by rating or date in different order
* Write errors to logs
* Separate class into different services

### Author
Kristen Cutler
