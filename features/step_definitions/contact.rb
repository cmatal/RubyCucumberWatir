require "rubygems"
require "watir"

browser = Watir::Browser.new :chrome

# data
$prefix = 'Mr.'
$first_name = 'First'
$last_name = 'Last'
$street = '4505 Maryland Pkwy'
$city = 'Las Vegas'
$state = 'NV'

Given(/^an associated admin user is navigating in the Manage Contacts page$/) do
  username = YAML.load_file("config.yml")['username']
  password = YAML.load_file("config.yml")['password']
  browser.goto('https://www.votervoice.net/AdminSite/')
  browser.input(name: 'username').send_keys username
  browser.input(name: 'password').send_keys password
  browser.button(type: 'submit').click
  browser.span(text: 'People').hover
  browser.link(text: 'Manage Contacts').click
end

When(/^the user clicks on the New Contact button$/) do
  browser.link(class: 'vv-link-add').click
end

And(/^fills up the required information using the default group list$/) do
  browser.wait_until { |browser| browser.link(class: 'ng-binding', text: 'Info') }
  browser.input(id: 'Honorific', visible: true).send_keys $prefix
  browser.send_keys :tab
  browser.inputs(xpath: "//input[@ng-model='profile.givenNames']").first.send_keys $first_name
  browser.inputs(xpath: "//input[@ng-model='profile.surname']").first.send_keys $last_name
  browser.inputs(xpath: "//input[@ng-model='profile.homeAddress.streetAddress1']").first.send_keys $street
  browser.inputs(xpath: "//input[@ng-model='profile.homeAddress.city']").first.send_keys $city
  browser.select_list(xpath: "//select[@ng-model='profile.homeAddress.state']").select $state
  browser.wait_until { |browser| browser.span(xpath: "//span[@ng-show='profile.homeAddress.isValid === true']") }
  puts 'Zip code populated'
  browser.wait_until { |browser|
    browser.span(xpath: "//select[@ng-model = 'profile.membership.groupList']/option[@selected = 'selected'][text() = 'Default List']")
  }
  puts 'Group List was set to Default List'
end

Then(/^a new user is created and validated$/) do
  browser.buttons(xpath: "//button[@ng-disabled = 'savingContact']").first.click
  browser.wait_until { |browser| browser.elements(xpath: "//div[@ng-show = 'successMessage != null']").first }
  browser.wait_until { |browser|
    browser.element(xpath: "//span[@class = 'ng-binding vv-contact-profile-name'][contains(text(), '#{$prefix + ' ' + $first_name + ' ' + $last_name}')]")
  }
  browser.wait_until { |browser|
    browser.element(xpath: "//div[@ng-show = 'profile.homeAddress!==null']/div[2][contains(text(), '#{$street + ', ' + $city + ' ' + $state}')]")
  }
  puts 'Contact was successfully saved and validated'
end

When(/^the user access the Default List$/) do
  browser.link(text: 'Default List').click
  browser.wait_until { |browser| browser.link(class: 'vv-link-delete') }
end

And(/^validates that the newly created contact exists$/) do
  browser.wait_until { |browser| browser.td(title: "#{$last_name} + ', ' + #{$first_name}") }
end

Then(/^the user is able to Delete the contact$/) do
  browser.link(class: 'vv-link-delete').click
  browser.span(class: 'ui-button-text', text: 'OK').click
  browser.link(class: 'vv-link-delete').wait_while(&:present?)
  puts 'No more contacts are listed in the Default List'
end

And(/^the user logs out and closes the browser$/) do
  browser.element(xpath: "//div[@id = 'adminLoggedIn']/img[@alt = 'open']").click
  browser.link(id: 'logout').click
  browser.close
end