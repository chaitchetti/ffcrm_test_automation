require 'selenium-webdriver'

webdriver_path = 'C:/Users/ymanral/Chromedriver/chromedriver.exe'
ENV['webdriver.chrome.driver'] = webdriver_path

browser = Selenium::WebDriver.for :chrome

browser.manage.window.maximize

# Function to login
def login(browser, username, password)
  browser.get('http://34.211.123.109:3000/')

  # Hover over the username field
  username_field = browser.find_element(id: 'user_email')
  browser.action.move_to(username_field).perform

  # Enter the username
  username_field.send_keys(username)

  # Move to the password field
  password_field = browser.find_element(id: 'user_password')
  browser.action.move_to(password_field).perform

  # Enter the password
  password_field.send_keys(password)

  # Click the login button using CSS selector
  login_button = browser.find_element(css: 'input[type="submit"]')
  login_button.click

  # Check if you are on the homepage after login
  homepage_element = browser.find_element(id: 'welcome') rescue nil
  if homepage_element&.displayed?
    puts "Login successful. You are on the homepage."
  else
    puts "Login failed. Unable to locate homepage element."
  end
end


# Function to create an account
def create_account(browser, name)

    # Click on the Accounts tab
    accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab.click

    # Click on the Create Account button
    create_account_button = browser.find_element(xpath: '//a[text()="Create Account"]')
    create_account_button.click

    # Fill in the Name field
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # Adjust the timeout as needed
    name_field = wait.until { browser.find_element(id: 'account_name') }
    name_field.send_keys(name)

    # Click the Create Account button
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # Adjust the timeout as needed
    create_account_button_final = wait.until { browser.find_element(xpath: '//input[@value="Create Account"]') }
    create_account_button_final.click
    sleep(100)

    # Check if the account is created
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    confirmation_message = wait.until { browser.find_element(class: 'indent') }
    if confirmation_message&.displayed?
        puts "Account creation successful. #{confirmation_message.text}"
    else
        puts "Account creation failed. Unable to locate confirmation message."
    end
end

# Example usage
begin
  login(browser, 'test', 'test') # Logging in as a test user
  create_account(browser, 'chaita') # Creating an account with the name 'chaita'
  sleep(40)
rescue StandardError => e
  puts "Error: #{e.message}"
ensure
  browser.quit
end
