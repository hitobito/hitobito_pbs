require 'spec_helper'

describe 'people/_form.html.haml' do
  let(:group) { person.primary_group }
  let(:person) do
    people(:bulei)
  end
  let(:stubs) {
    { path_args: [group, person], model_class: Person, entry: person }
  }

  before do
    allow(view).to receive_messages(stubs)
    allow(controller).to receive_messages(current_user: person)
  end

  let(:dom) do
    render partial: "people/form"
    Capybara::Node::Simple.new(rendered)
  end

  describe "prefers_digital_correspondence" do
    it "renders field" do
      expect(dom).to have_css("label", text: "Digitale Korrespondenz bevorzugt")
      expect(dom).to have_css("input[name='person[prefers_digital_correspondence]']")
    end
  end

end
