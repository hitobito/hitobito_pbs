require "spec_helper"

describe Crisis do
  context "validation" do
    it "cannot create second active crisis in same group" do
      crisis = groups(:schekka).crises.build(creator: people(:bulei))
      expect(crisis).to have(1).errors_on(:base)
      expect(crisis.errors.full_messages.join("/n"))
        .to match(/Eine andere Krise ist bereits aktiv auf dieser Gruppe/)
    end
  end
end
