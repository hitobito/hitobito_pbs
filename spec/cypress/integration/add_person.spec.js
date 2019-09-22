describe('The user', function () {
  beforeEach(() => {
    cy.login("kunz@puzzle.ch", "hito42bito")
  })
  it('can add a new person', function () {
    cy.visit('de/groups/1/roles/new')

    cy.get('a:contains("Neue Person erfassen")').click()

    cy.get('#role_new_person_first_name')
      .type('Marlies')
    cy.get('#role_new_person_last_name')
      .type('Sauerkraut')
    cy.get('#role_new_person_nickname')
      .type('Brexit')
    cy.get('#role_new_person_email')
      .type('marlies_sk88@example.com')

    cy.get('#role_type_select').click()
    cy.get('div.chosen-search input').type("Gesch{enter}")

    cy.get('form#new_role button[type="submit"]:first').click()
  })
})