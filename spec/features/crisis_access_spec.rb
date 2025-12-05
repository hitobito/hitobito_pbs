# frozen_string_literal: true

#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs

require "spec_helper"

describe "Crisis access", js: true do
  let(:user) { people(:be_crisis_member) }
  let(:child) { people(:child) }

  it "gives access on all people when user has triggered crisis on the same layer" do
    Crisis.active.destroy_all # Start with a clean slate
    sign_in(user)

    visit group_people_path(groups(:pegasus))
    expect(page).to have_text("0 Personen angezeigt. 1 weitere Person ist für dich nicht sichtbar.")

    visit group_path(groups(:schekka))
    accept_confirm do
      click_on("Krise")
    end
    expect(page).to have_text("hat auf dieser Gruppe eine Krise ausgelöst")

    visit group_people_path(groups(:pegasus))
    expect(page).to have_text("1 Person angezeigt.")
    expect(page).to have_element("tr", id: "person_#{child.id}")
    child_link = page.find("tr", id: "person_#{child.id}").first("a")
    child_link.click

    assert_current_path group_person_path(groups(:pegasus), child)
    expect(page).to have_text(child.full_name)
  end
end
