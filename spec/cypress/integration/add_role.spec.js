describe('The user', function () {
	beforeEach(() => {
	  cy.login("kunz@puzzle.ch", "hito42bito")
	})
	it('can add a role', function () {
	  cy.visit("/de/groups/1/people/18")

		cy.get('a.btn.btn-small:contains("Rolle hinzufügen")').click()
		cy.get('#role_type_select').click()

		cy.get('div.chosen-search input').type("Webma{enter}")
		cy.get('#new_role button[type=submit]').last().click()

    cy.contains("Rolle Webmaster für Muhammed Stang / Beatae in Pfadibewegung Schweiz wurde erfolgreich erstellt.")
	})
})
