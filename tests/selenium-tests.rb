require 'selenium-webdriver'
require 'test-unit'
class AutomaticTest < Test::Unit::TestCase

def setup
  @driver = Selenium::WebDriver.for :firefox
  @url = "http://localhost"
  @driver.manage.timeouts.implicit_wait = 30;
 end

def test_main_page
  @driver.get(@url)
  @query_box = @driver.find_element(:name, 'search-input')
  @query_box.send_keys("11")
  @query_box.submit
  @myDynamicElement = @driver.find_element(:id, 'results-count')
  p @myDynamicElement.text
 end

def teardown
  @driver.quit
 end

end
