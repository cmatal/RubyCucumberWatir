@contact
Feature: Contacts
  As an association admin user, I should be able to create and delete contacts on the Manage Contacts Page

  Scenario: Add new contact to the empty Default List
    Given an associated admin user is navigating in the Manage Contacts page
    When the user clicks on the New Contact button
    And fills up the required information using the default group list
    Then a new user is created and validated
    And the user logs out

  Scenario: Delete single existing contact from Default List
    Given an associated admin user is navigating in the Manage Contacts page
    When the user access the Default List
    And validates that the newly created contact exists
    Then the user is able to Delete the contact
    And the user logs out

