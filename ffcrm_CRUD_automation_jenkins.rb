require 'selenium-webdriver'
require 'yaml'

include Selenium::WebDriver::Error

# Load parameters from config.yaml
#config = YAML.load_file('config.yaml')
config = YAML.safe_load(File.read('config.yaml'))


chrome_driver_path = config['chrome_driver_path']
username = config['username']
password = config['password']
account_name = config['account_name']
task_name = config['task_name']
ffcrm_server_link = config['ffcrm_server_link']

# Initialize Chrome WebDriver with the specified path
Selenium::WebDriver::Chrome::Service.driver_path = chrome_driver_path
options = Selenium::WebDriver::Chrome::Options.new

# Headless mode
options.add_argument('--headless')
options.add_argument('--disable-gpu') # Add this line to disable GPU acceleration

# Set window size explicitly
options.add_argument('--window-size=1920,1080')  # Adjust the size as needed

# Create a new instance of Chrome WebDriver
browser = Selenium::WebDriver.for :chrome, options: options

# Helper function for waiting for an element
def wait_for_element(browser, by, value, timeout)
  wait = Selenium::WebDriver::Wait.new(timeout: timeout)
  begin
    element = wait.until { browser.find_element(by, value) }
    puts "Element located: #{by} => #{value}"
    return element
  rescue StandardError => e
    puts "Timed out or Error locating element: #{by} => #{value}, Error: #{e.message}"
    return nil
  end
end

def scroll_into_view(browser, element)
  browser.execute_script("arguments[0] && arguments[0].scrollIntoView(true);", element)
end

# Function to login
def login(browser, username, password,ffcrm_server_link)

    puts "ffcrm_server_link before login: #{ffcrm_server_link}"
    browser.get(ffcrm_server_link)

    # Hover over the username field
    username_field = wait_for_element(browser, :id, 'user_email', 10)
    browser.action.move_to(username_field).perform

    # Enter the username
    username_field.send_keys(username)

    # Move to the password field
    password_field = wait_for_element(browser, :id, 'user_password', 10)
    browser.action.move_to(password_field).perform

    # Enter the password
    password_field.send_keys(password)

    # Click the login button using CSS selector
    login_button = wait_for_element(browser, :css, 'input[type="submit"]', 10)
    login_button.click

    # Check if you are on the homepage after login
    homepage_element = wait_for_element(browser, :id, 'welcome', 10)
    if homepage_element&.displayed?
        puts "Login successful. You are on the homepage."
    else
        puts "Login failed. Unable to locate homepage element."
    end
end

# Function to create an account
def create_account(browser, name)

    puts 'Inside create account function'
    # Click on the Accounts tab
    #accounts_tab = wait_for_element(browser, :xpath, '//ul[@id="navbarNav"]/li[5]', 20)
    accounts_tab = wait_for_element(browser, :css, 'a.nav-link[href="/accounts"]', 20)
    browser.execute_script("arguments[0].scrollIntoView(true); arguments[0].click();", accounts_tab)
    puts 'Accounts tab clicked'
    sleep(60)

    # Click on the Create Account button
    puts 'Initialized Create Account button'
    create_account_button = wait_for_element(browser, :xpath, '//a[contains(text(),"Create Account")]', 10)
    # Capture a screenshot if the "Create Account" button is not found
    if create_account_button.nil?
        timestamp = Time.now.strftime('%Y%m%d%H%M%S')
        screenshot_path = "C:/Users/ymanral/Desktop/error_screenshot_#{timestamp}.png"
        browser.save_screenshot(screenshot_path)
        puts "Screenshot saved to: #{screenshot_path}"
        raise "Error: 'Create Account' button not found."
    end
    #create_account_button = wait_for_element(browser, :link_text, 'Create Account', 10)
    scroll_into_view(browser, create_account_button)
    create_account_button.click
    #browser.execute_script("arguments[0].scrollIntoView(true); arguments[0].click();", create_account_button) 
    puts 'Create Account button clicked'

    # Fill in the Name field
    #wait = Selenium::WebDriver::Wait.new(timeout: 10) # Adjust the timeout as needed
    name_field = wait_for_element(browser, :id, 'account_name', 10)
    name_field.send_keys(name)

    # Click the Create Account button
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # Adjust the timeout as needed
    create_account_button_final = wait_for_element(browser, :xpath, '//input[@value="Create Account"]', 10)
    create_account_button_final.click
    sleep(10)

    # Check if the account is created
    confirmation_message = wait_for_element(browser, :class, 'indent', 10)
    if confirmation_message&.displayed?
        puts "Account creation successful. #{confirmation_message.text}"
    else
        puts "Account creation failed. Unable to locate confirmation message."
    end
    browser.manage.timeouts.implicit_wait = 30

end

def read_account(browser, username)
    # Click on the Accounts tab
    accounts_tab = wait_for_element(browser, :xpath, '//ul[@id="navbarNav"]/li[5]', 10)
    accounts_tab.click

    # Click on the Advanced Search tab
    advanced_search_tab = wait_for_element(browser, :xpath, '//a[contains(text(), "Advanced search")]', 10)
    advanced_search_tab.click

    # Select "Name" in the Account dropdown
    account_dropdown = wait_for_element(browser, :id, 'q_g_0_c_0_a_0_name', 10)
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)

    # Click on the dropdown to open options
    account_dropdown.click

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(5)  # Adjust sleep time if needed

    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 5 seconds."

    # Enter the account name in the text field
    search_text_field = wait_for_element(browser, :id, 'q_g_0_c_0_v_0_value', 10)
    search_text_field.send_keys(username)

    # Click on the Search button
    wait_for_element(browser, :css, '.btn.btn-primary.btn-large.submit-search', 10).click

    # Click on the account in the search results
    search_result_account_link = wait_for_element(browser, :xpath, "//a[contains(text(), '#{username}') and contains(@href, '/accounts/')]", 10)
    search_result_account_link.click

    # Explicitly wait for the confirmation message
   #confirmation_message = wait_for_element(browser, :class, 'indent', 10)

    #if confirmation_message.nil?
        #puts "Timed out waiting for confirmation message."
    #else
        #puts "Account details read successfully. #{confirmation_message.text}"
    #end
end


def update_account(browser, username, task_name)
    #accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab = wait_for_element(browser, :xpath, '//ul[@id="navbarNav"]/li[5]', 10)
    accounts_tab.click

    # Click on the Advanced Search tab
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #advanced_search_tab = wait.until { browser.find_element(xpath: '//a[contains(text(), "Advanced search")]') }
    advanced_search_tab = wait_for_element(browser, :xpath, '//a[contains(text(), "Advanced search")]', 10)
    advanced_search_tab.click

    # Select "Name" in the Account dropdown
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #account_dropdown = wait.until { browser.find_element(id: 'q_g_0_c_0_a_0_name') }
    account_dropdown = wait_for_element(browser, :id, 'q_g_0_c_0_a_0_name', 10)
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)

    # Click on the dropdown to open options
    account_dropdown.click

    # Wait for the dropdown options to appear
    #wait.until { account_select.options.any? }
    #wait_for_element(browser, :xpath, "//span[@id='select2-task_bucket-container']/following::ul[@class='select2-results__options']/li", 10)
    account_dropdown = wait_for_element(browser, :id, 'q_g_0_c_0_a_0_name', 10)
    account_dropdown.click

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(10)

    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 10 seconds."

    # Enter the account name in the text field
    #search_text_field = wait.until { browser.find_element(id: 'q_g_0_c_0_v_0_value') }
    search_text_field = wait_for_element(browser, :id, 'q_g_0_c_0_v_0_value', 10)
    search_text_field.send_keys(username)

    # Click on the Search button
    #search_button = browser.find_element(css: '.btn.btn-primary.btn-large.submit-search')
    search_button = wait_for_element(browser, :css, '.btn.btn-primary.btn-large.submit-search', 10)
    search_button.click

    # Click on the account in the search results
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #search_result_account_link = browser.find_element(xpath: '//a[contains(text(), "chaita") and contains(@href, "/accounts/")]')
    search_result_account_link = wait_for_element(browser, :xpath, "//a[contains(text(), '#{username}') and contains(@href, '/accounts/')]", 10)
    search_result_account_link.click

    # Click on "Create Task" link
    create_task_link_xpath = '//a[contains(text(), "Create Task") and contains(@href, "/tasks/new?cancel=false&related=account_")]'
    create_task_link = wait_for_element(browser, :xpath, create_task_link_xpath, 10)

    # Scroll into view to make the element visible
    browser.execute_script("arguments[0].scrollIntoView(true);", create_task_link)

    # Check if the "Create Task" link is clickable and enabled
    if create_task_link.enabled?
        # Click on the "Create Task" link
        create_task_link.click

        # Debugging output
        puts "Before clicking on 'Create Task' link"
        puts "After clicking on 'Create Task' link"
    else
        puts "The 'Create Task' link is not clickable."
    end

    # Explicitly wait for the presence of the task form
    wait_for_element(browser, :id, 'task_name', 10)

    # Enter task details
    task_name_field = browser.find_element(id: 'task_name')
    task_name_field.send_keys(task_name)

    # Select a random option from the Due dropdown
    due_dropdown = browser.find_element(id: 'select2-task_bucket-container')
    due_dropdown.click
    due_options = browser.find_elements(xpath: '//span[@id="select2-task_bucket-container"]/following::ul[@class="select2-results__options"]/li')
    random_due_option = due_options.sample
    random_due_option.click

    # Select a random option from the Assign To dropdown
    assign_to_dropdown = browser.find_element(id: 'select2-task_assigned_to-container')
    assign_to_dropdown.click
    assign_to_options = browser.find_elements(xpath: '//span[@id="select2-task_assigned_to-container"]/following::ul[@class="select2-results__options"]/li')
    random_assign_to_option = assign_to_options.sample
    random_assign_to_option.click

    # Select a random option from the Category dropdown
    category_dropdown = browser.find_element(id: 'select2-task_category-container')
    category_dropdown.click
    category_options = browser.find_elements(xpath: '//span[@id="select2-task_category-container"]/following::ul[@class="select2-results__options"]/li')
    random_category_option = category_options.sample
    random_category_option.click

    # Click on "Create Task" button
    create_task_button = browser.find_element(xpath: '//input[@value="Create Task"]')
    create_task_button.click
  end

# Function to delete an account
def delete_account(browser, username)

    #accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab = wait_for_element(browser, :xpath, '//ul[@id="navbarNav"]/li[5]', 10)
    accounts_tab.click

    # Click on the Advanced Search tab
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #advanced_search_tab = wait.until { browser.find_element(xpath: '//a[contains(text(), "Advanced search")]') }
    advanced_search_tab = wait_for_element(browser, :xpath, '//a[contains(text(), "Advanced search")]', 10)
    advanced_search_tab.click

    # Select "Name" in the Account dropdown
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #account_dropdown = wait.until { browser.find_element(id: 'q_g_0_c_0_a_0_name') }
    account_dropdown = wait_for_element(browser, :id, 'q_g_0_c_0_a_0_name', 10)
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)

    # Click on the dropdown to open options
    account_dropdown.click

    # Wait for the dropdown options to appear
    #wait.until { account_select.options.any? }
    #wait_for_element(browser, :xpath, "//span[@id='select2-task_bucket-container']/following::ul[@class='select2-results__options']/li", 10)
    account_dropdown = wait_for_element(browser, :id, 'q_g_0_c_0_a_0_name', 10)
    account_dropdown.click

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(10)

    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 10 seconds."

    # Enter the account name in the text field
    #search_text_field = wait.until { browser.find_element(id: 'q_g_0_c_0_v_0_value') }
    search_text_field = wait_for_element(browser, :id, 'q_g_0_c_0_v_0_value', 10)
    search_text_field.send_keys(username)

    # Click on the Search button
    #search_button = browser.find_element(css: '.btn.btn-primary.btn-large.submit-search')
    search_button = wait_for_element(browser, :css, '.btn.btn-primary.btn-large.submit-search', 10)
    search_button.click

    # Click on the account in the search results
    #wait = Selenium::WebDriver::Wait.new(timeout: 10)
    #search_result_account_link = browser.find_element(xpath: '//a[contains(text(), "chaita") and contains(@href, "/accounts/")]')
    search_result_account_link = wait_for_element(browser, :xpath, "//a[contains(text(), '#{username}') and contains(@href, '/accounts/')]", 10)
    search_result_account_link.click

    # Execute JavaScript to trigger delete action
    browser.execute_script("$('#menu a:contains(\"Delete\")').click();")

    # Click on "Yes" option
    confirm_yes_button = wait_for_element(browser, :xpath, "//a[contains(text(), 'Yes') and @data-method='delete']", 10)
    puts "Confirm Yes button visibility: #{confirm_yes_button.displayed?}" # Debugging statement
    confirm_yes_button.click

    # Wait for the deletion confirmation message (adjust timeout as needed)
    wait_for_element(browser, :class, 'flash_notice', 10)

    puts "Account deletion successful."
end

# Example usage
begin
    login(browser, config['username'], config['password'],config['ffcrm_server_link'])
    create_account(browser, config['account_name'])
    read_account(browser, config['account_name'])
    update_account(browser, config['account_name'], config['task_name'])
    delete_account(browser, config['account_name'])
    sleep(40)
rescue Selenium::WebDriver::Error::NoSuchElementError, StandardError => e
    puts "Error: #{e.message}"
    # Capture a screenshot
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    screenshot_path = "C:/Users/ymanral/Desktop/error_screenshot_#{timestamp}.png"
    browser.save_screenshot(screenshot_path)
    puts "Screenshot saved to: #{screenshot_path}"
    # Raise the original error after capturing the screenshot
    raise e
#ensure
    #browser.quit
end


  # Function to select a random option from a dropdown
def select_random_option(browser, dropdown_id)

    dropdown_options = browser.find_elements(xpath: "//ul[@id='#{dropdown_id}-results']/li")
    random_option = dropdown_options.sample
    random_option.click
end

