require 'selenium-webdriver'
require 'test-unit'
class AutomaticTest < Test::Unit::TestCase

def setup
  @driver = Selenium::WebDriver.for :chrome
  @url = "localhost:4567"
  @driver.manage.timeouts.implicit_wait = 30
 end

def test_main_page
  @driver.get(@url)
# Search for the search box using the name selector
  @query_box = @driver.find_element(:name, 'search-input')
# Input the search phrase we need to search for in the searched query_box element
  @query_box.send_keys("11")
# Click submit button(enter to search)
  @query_box.submit
 end

def teardown
  @driver.quit
 end

end
