#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe "event/participations/_form.html.haml" do
  let(:participant) { people(:bulei) }
  let(:participation) { event_participations(:top_participant) }
  let(:event) { events(:top_course) }
  let(:group) { event.groups.first }
  let(:dom) { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive_messages(current_user: participant,
      path_args: [group, event, participation],
      model_class: Event::Participation)

    allow(view).to receive_messages(entry: participation.decorate, submit_label: "Speichern",
      add_another: false, add_another_label: "")
    allow(controller).to receive_messages(current_user: participant)
    assign(:event, event.decorate)
    assign(:group, group)
    assign(:answers, participation.answers)
  end

  it "includes documents_text in application" do
    event.kind.update(documents_text: "some documents text")
    render
    expect(dom).to have_content "some documents text"
  end

  context "js data sharing agreement checkbox" do
    it "is included when participation.j_s_data_sharing_acceptance_required? is true" do
      event.update(j_s_kind: Pbs::Event::J_S_KINDS_DATA_SHARING_ACCEPTANCE.first)
      participation.update_column(:j_s_data_sharing_accepted_at, nil)
      expect(participation.j_s_data_sharing_acceptance_required?).to eq true
      render
      expect(dom).to have_field :event_participation_j_s_data_sharing_accepted
    end

    it "is shown disabled if already accepted before" do
      event.update(j_s_kind: Pbs::Event::J_S_KINDS_DATA_SHARING_ACCEPTANCE.first)
      participation.update(j_s_data_sharing_accepted_at: Time.zone.now)
      expect(participation.j_s_data_sharing_acceptance_required?).to eq true
      render
      expect(dom).to have_checked_field :event_participation_j_s_data_sharing_accepted,
        disabled: true
    end

    it "is not included when participation.j_s_data_sharing_acceptance_required? is false" do
      event.update(j_s_kind: "j_s_kind_none")
      participation.update_column(:j_s_data_sharing_accepted_at, nil)
      expect(participation.j_s_data_sharing_acceptance_required?).to eq false
      render
      expect(dom).not_to have_field :event_participation_j_s_data_sharing_accepted
      expect(dom).not_to have_field :event_participation_j_s_data_sharing_accepted, disabled: true
    end
  end
end
