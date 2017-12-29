require 'capybara/dsl'
require 'selenium-webdriver'
require 'pry'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :chrome

Capybara.configure do |config|
  config.default_max_wait_time = 10 # seconds
  config.default_driver = :selenium
end


class Linkdin

  include Capybara::DSL

  def scroll_to_bottom
    page.execute_script('window.scrollTo(0,100000)')
  end

  def login(email, password)
    find('#login-email').set(email)
    find('#login-password').set(password)
    find('#login-submit').click
  end

  def my_network
    find('#mynetwork-tab-icon').click
  end

  def visit_site(url)
    visit url
  end

  def people_may_know
    within find('.mn-pymk-list__cards') do
      all('.mn-person-info__card-details', :minimum => 3)
    end
  end

  def qas?(string)
    # key words to search for:
    # if user has: "sqa" or "test engineer" or "quality assurance" or "software qa" or "qa engineer"
    # u can add more ey word to the regex...syntax: |\b<key words>\b

    regex = /\bsqa\b|\btest engineer\b|\bquality assurance\b|\bsoftware qa\b|\bqa engineer\b/

    if regex.match(string.downcase)
      return true
    else
      false
    end
  end

  def get_testers
    qas = []
    people_may_know.each do |user|
      if qas?(user.text)
        qas << user
        puts user.text
      end
    end
    qas
  end

  def connect_testers
    begin
      get_testers.each do |qa|
        qa.find(:xpath, '..').find('span', :text => "Connect").click
        puts "User connected: #{qa.text}"
      end
      puts "TOTAL connected users: #{get_testers.size}"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      puts '-----------------------------'
    end

  end

end

linkdin = Linkdin.new

linkdin.visit_site("https://www.linkedin.com")

# login to the web site:
email, password = ENV['email'], ENV['password']
linkdin.login(email, password)

# go to my network:
linkdin.my_network

number_of_scrolls = 0

while number_of_scrolls < 5 #number of iterations = 5, change it if you want more.
  linkdin.connect_testers
  number_of_scrolls += 1
  linkdin.scroll_to_bottom
end
