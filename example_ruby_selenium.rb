require 'selenium-webdriver'

# Set the path to the ChromeDriver executable
chrome_driver_path = '/usr/local/bin/chromedriver'

# Initialize Chrome WebDriver with the specified path
Selenium::WebDriver::Chrome::Service.driver_path = chrome_driver_path
options = Selenium::WebDriver::Chrome::Options.new

# Headless mode
options.add_argument('--headless')
options.add_argument('--disable-gpu') # Add this line to disable GPU acceleration

# Create a new instance of Chrome WebDriver
driver = Selenium::WebDriver.for :chrome, options: options

# Navigate to Google
driver.get('https://www.google.com')

# Find the search input field by name
search_box = driver.find_element(name: 'q')

# Type a search query
search_box.send_keys('Selenium WebDriver')

# Submit the form (press Enter)
search_box.submit

# Wait for the search results page to load
wait = Selenium::WebDriver::Wait.new(timeout: 10)
wait.until { driver.title.start_with?('Selenium WebDriver') }

# Print the title of the search result page
puts "Search results title: #{driver.title}"

# Close the browser
driver.quit
