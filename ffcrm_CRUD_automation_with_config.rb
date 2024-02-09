require 'selenium-webdriver'
require 'yaml'

# Load parameters from config.yaml
config = YAML.load_file('C:/Users/ymanral/Desktop/config.yaml')

webdriver_path = 'C:/Users/ymanral/Chromedriver/chromedriver.exe'
ENV['webdriver.chrome.driver'] = webdriver_path
username = config['username']
password = config['password']
account_name = config['account_name']
task_name = config['task_name']

browser = Selenium::WebDriver.for :chrome

browser.manage.window.maximize

# Helper function for waiting for an element
def wait_for_element(browser, by, value, timeout)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout)
    wait.until { browser.find_element(by, value) rescue nil }
end


# Function to login
def login(browser, username, password)
    
    browser.get('http://50.112.231.151:3000/') 

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
    sleep(10)  
  
    # Check if the account is created
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    confirmation_message = wait.until { browser.find_element(class: 'indent') }
    if confirmation_message&.displayed?
        puts "Account creation successful. #{confirmation_message.text}"
    else
        puts "Account creation failed. Unable to locate confirmation message."
    end
end

# Function to read account details with advanced search
def read_account(browser, username)
    # Click on the Accounts tab
    accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab.click
  
    # Click on the Advanced Search tab
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    advanced_search_tab = wait.until { browser.find_element(xpath: '//a[contains(text(), "Advanced search")]') }
    advanced_search_tab.click
  
    # Select "Name" in the Account dropdown
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    account_dropdown = wait.until { browser.find_element(id: 'q_g_0_c_0_a_0_name') }
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)
  
   # Click on the dropdown to open options
    account_dropdown.click

    # Wait for the dropdown options to appear
    wait.until { account_select.options.any? }

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(10)
  
    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 10 seconds."  

    # Enter the account name in the text field
    search_text_field = wait.until { browser.find_element(id: 'q_g_0_c_0_v_0_value') }
    search_text_field.send_keys(username)
    
    # Click on the Search button
    search_button = browser.find_element(css: '.btn.btn-primary.btn-large.submit-search')
    search_button.click

    # Click on the account in the search results
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    search_result_account_link = browser.find_element(xpath: '//a[contains(text(), "chaita") and contains(@href, "/accounts/")]')
    search_result_account_link.click

end

def update_account(browser, username, task_name)
    accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab.click

    # Click on the Advanced Search tab
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    advanced_search_tab = wait.until { browser.find_element(xpath: '//a[contains(text(), "Advanced search")]') }
    advanced_search_tab.click

    # Select "Name" in the Account dropdown
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    account_dropdown = wait.until { browser.find_element(id: 'q_g_0_c_0_a_0_name') }
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)

    # Click on the dropdown to open options
    account_dropdown.click

    # Wait for the dropdown options to appear
    wait.until { account_select.options.any? }

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(10)

    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 10 seconds."  

    # Enter the account name in the text field
    search_text_field = wait.until { browser.find_element(id: 'q_g_0_c_0_v_0_value') }
    search_text_field.send_keys(username)
    
    # Click on the Search button
    search_button = browser.find_element(css: '.btn.btn-primary.btn-large.submit-search')
    search_button.click

    # Click on the account in the search results
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    search_result_account_link = browser.find_element(xpath: '//a[contains(text(), "chaita") and contains(@href, "/accounts/")]')
    search_result_account_link.click

    # Click on "Create Task" link
    create_task_link_xpath = '//a[contains(text(), "Create Task") and contains(@href, "/tasks/new?cancel=false&related=account_")]'
    create_task_link = wait.until { browser.find_element(xpath: create_task_link_xpath) }

    # Scroll into view to make the element visible
    browser.execute_script("arguments[0].scrollIntoView(true);", create_task_link)

    if wait.until { create_task_link.enabled? rescue false }
      # Click on the "Create Task" link
      create_task_link.click

      # Debugging output
      puts "Before clicking on 'Create Task' link"
      puts "After clicking on 'Create Task' link"
    else
      puts "The 'Create Task' link is not clickable."
    end

    # Explicitly wait for the presence of the task form
    wait.until { browser.find_element(id: 'task_name').displayed? }

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

    accounts_tab = browser.find_element(xpath: '//ul[@id="navbarNav"]/li[5]')
    accounts_tab.click

    # Click on the Advanced Search tab
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    advanced_search_tab = wait.until { browser.find_element(xpath: '//a[contains(text(), "Advanced search")]') }
    advanced_search_tab.click

    # Select "Name" in the Account dropdown
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    account_dropdown = wait.until { browser.find_element(id: 'q_g_0_c_0_a_0_name') }
    account_select = Selenium::WebDriver::Support::Select.new(account_dropdown)

    # Click on the dropdown to open options
    account_dropdown.click

    # Wait for the dropdown options to appear
    wait.until { account_select.options.any? }

    # Select "Name" in the Account dropdown
    account_select.select_by(:text, 'Name')
    sleep(10)

    # Print a message indicating the selection
    puts "Selected 'Name' in the Account dropdown and waited for 10 seconds."  

    # Enter the account name in the text field
    search_text_field = wait.until { browser.find_element(id: 'q_g_0_c_0_v_0_value') }
    search_text_field.send_keys(username)
        
    # Click on the Search button
    search_button = browser.find_element(css: '.btn.btn-primary.btn-large.submit-search')
    search_button.click

    # Click on the account in the search results
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    search_result_account_link = browser.find_element(xpath: '//a[contains(text(), "chaita") and contains(@href, "/accounts/")]')
    search_result_account_link.click
    
    # Execute JavaScript to trigger delete action
    browser.execute_script("$('#menu a:contains(\"Delete\")').click();")

    # Click on "Yes" option
    confirm_yes_button = wait.until { browser.find_element(xpath: '//a[contains(text(), "Yes") and @data-method="delete"]').click }
    puts "Confirm Yes button visibility: #{confirm_yes_button.displayed?}" # Debugging statement
    confirm_yes_button.click

    # Wait for the deletion confirmation message (adjust timeout as needed)
    wait.until { browser.find_element(class: 'flash_notice') }

    puts "Account deletion successful."
end

# Example usage
begin
    login(browser, config['username'], config['password'])
    create_account(browser, config['account_name'])
    read_account(browser, config['account_name'])
    update_account(browser, config['account_name'], config['task_name'])
    delete_account(browser, config['account_name'])
    sleep(40)
rescue Selenium::WebDriver::Error::NoSuchElementError, StandardError => e
    puts "Error: #{e.message}"
ensure
    browser.quit
end

  
  # Function to select a random option from a dropdown
def select_random_option(browser, dropdown_id)

    dropdown_options = browser.find_elements(xpath: "//ul[@id='#{dropdown_id}-results']/li")
    random_option = dropdown_options.sample
    random_option.click
end
