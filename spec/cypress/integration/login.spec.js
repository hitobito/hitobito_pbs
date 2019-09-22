describe('The login page', () => {

  const testLogin = () => {
    cy.visit('/')
    cy.get('#person_email')
      .type('kunz@puzzle.ch')
    cy.get('#person_password')
      .type('hito42bito')
    return cy.get('button.btn.btn-primary').click()
  }

  it('successfully loads', () => {
    cy.visit('/')
  })
  it("successfully logs in a valid user", () => {
    testLogin()
    cy.url().should('not.contain', "users/sign_in")
  })
  it("correctly redirects after login", () => {
    testLogin()
    cy.url().should('match', /groups\/\d+\/people\/\d+\.html$/)
  })
})
