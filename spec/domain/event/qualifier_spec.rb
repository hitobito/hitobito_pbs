require 'spec_helper'

describe Event::Qualifier do

  let(:course) { events(:bund_course) }

  let(:participation) do
    participation = Fabricate(:pbs_participation, event: course)
    Fabricate(Event::Role::Participant.name.to_sym, participation: participation)
    participation.reload
  end

  let(:participant)      { participation.person }

  let(:participant_qualifier) { Event::Qualifier.for(participation) }
  let(:quali_date)       { Date.new(2012, 10, 20) }

  context '#issue' do

    it "saves the participation on the qualification" do
      participant_qualifier.issue
      participant.reload.qualifications.each do |qualification|
        expect(qualification.event_participation).not_to be_nil
        expect(qualification.event_participation.person).to eq(participant)
      end
    end

  end

end
