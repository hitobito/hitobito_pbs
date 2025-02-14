#  Copyright (c) 2019-2025 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::ApplicationMarketController, js: true do
  let(:event) { Fabricate(:course, kind: event_kinds(:lpk)) }

  let(:group) { event.groups.first }

  let!(:appl_waiting) do
    Fabricate(:event_participation,
      application: Fabricate(:event_application, waiting_list: true, priority_1: event, priority_2: nil),
      event: Fabricate(:course, kind: event_kinds(:lpk)),
      person: people(:al_schekka))
  end

  it "displays custom error alert when person from national waiting list did not accept J&S data sharing" do
    allow_any_instance_of(Event).to receive(:j_s_data_sharing_acceptance_required?).and_return(true)
    sign_in(people(:bulei))
    visit group_event_application_market_index_path(group_id: group.id, event_id: event.id)
    find("#waiting_list").set(true)
    click_button("Aktualisieren")
    expect(page).to have_text("Schekka AL")
    find(".fa-arrow-left").click
    sleep(3)
    alert_text = page.driver.browser.switch_to.alert.text
    expect(alert_text).to include(
      "Diese Person hat bei der Anmledung für den anderen Kurs die J+S Datenweitergabe nicht akzeptiert, dieser ist für diesen Kurs Pflicht, " \
      "die Anmeldung ist daher leider nicht möglich."
    )
  end
end
