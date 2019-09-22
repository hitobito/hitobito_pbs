// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
Cypress.Commands.add("login", (email, password) => {
  Cypress.log({
    message: "login page",
    displayName: "Fetching"
  })
  cy.request({url: "/users/sign_in", log: false}).its("body").then(body => {
    Cypress.log({
      message: "a token",
      displayName: "has"
    })
    let form = Cypress.$(body).find("form#new_person")[0]
    let data = new FormData(form)

    data.set("person[email]", email)
    data.set("person[password]", password)

    let object = {};
    for (let pair of data.entries()) {
      object[pair[0]] = pair[1]
    }

    Cypress.log({
      message: "as " + email,
      displayName: "Logging in",
    })
    cy.request({
      url: "/users/sign_in",
      method: "POST",
      form: true,
      body: object,
      log: false,
    })
    Cypress.log({
      message: "successful!",
      displayName: "Login",
    })
  })
})

Cypress.Commands.add("logout", () => {
  Cypress.log({
    displayName: "Logging out"
  })
  cy.get("meta[name=csrf-token]").then(tag => {
    let token = tag.prop("content")
    cy.request({
      url: "/users/sign_out",
      method: "POST",
      form: true,
      body: {
        "_method": "delete",
        "authenticity_token": token
      },
      log: false,
    })
  })
})
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
