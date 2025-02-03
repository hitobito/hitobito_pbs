require "spec_helper"

describe Devise::Hitobito::SessionsController do
  render_views

  let(:hostname) { "be.local" }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:logo) { page.find("a.logo-image img") }

  before do
    request.env["devise.mapping"] = Devise.mappings[:person]
    groups(:be).update!(hostname: "be.local")
  end

  context "logo" do
    it "returns the default hostname" do
      request.host = "something-else.local"

      get :new

      expect(logo[:src]).to match %r{media/images/logo-.*\.svg}
    end

    it "Group with matching hostname but blank logo returns default logo" do
      request.host = hostname

      get :new

      expect(logo[:src]).to match %r{media/images/logo-.*\.svg}
    end

    it "Group with matching hostname and present logo returns group logo" do
      groups(:be).logo.attach(fixture_file_upload("images/logo.png", "image/png"))
      request.host = hostname

      get :new

      expect(logo[:src]).to match %r{active_storage/blobs/.*/logo\.png}
    end
  end
end
