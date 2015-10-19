require 'spec_helper'

describe Event::Camp do

  subject { events(:schekka_camp) }
  before { is_expected.to be_valid }

  context 'expected_participants' do
    it 'does not accept negative values' do
      subject.expected_participants_rover_f = -33
      is_expected.not_to be_valid
    end

    it 'does not accept non integer values' do
      subject.expected_participants_pio_m = 33.3
      is_expected.not_to be_valid
    end

    it 'accepts any positive integer' do
      subject.expected_participants_pio_m = 42
      is_expected.to be_valid
    end
  end

  context 'camp days' do
    it 'does not accept negative values' do
      subject.camp_days = -44
      is_expected.not_to be_valid
    end

    it 'accepts any positive integer' do
      subject.camp_days = 4
      is_expected.to be_valid
    end
  end

  context '#j_s_kind' do
    it 'accepts empty value' do
      subject.j_s_kind = nil
      is_expected.to be_valid

      subject.j_s_kind = ''
      is_expected.to be_valid
    end

    %w(j_s_child j_s_youth j_s_mixed).each do |kind|
      it "accepts '#{kind}'" do
        subject.j_s_kind = kind
        is_expected.to be_valid
      end
    end

    it 'does not accept any other string' do
      subject.j_s_kind = 'asdf'
      is_expected.not_to be_valid
    end
  end

  context '#application_possible' do
    it 'is possible if application dates are open and flag is set' do
      subject.application_opening_at = 5.days.ago
      subject.application_closing_at = 10.days.from_now

      expect(subject).not_to be_application_possible

      subject.participants_can_apply = true

      expect(subject).to be_application_possible

      subject.application_opening_at = 1.day.from_now

      expect(subject).not_to be_application_possible
    end
  end

  context 'advisor assignment info' do
    before do
      subject.coach_id = people(:al_berchtold).id
      subject.advisor_snow_security_id = people(:bulei).id
      subject.state = 'confirmed'
      subject.save!
    end

    it 'is not sent if nothing changed' do
      expect(subject).not_to receive(:delay)
      subject.update!(location: 'Bern')
    end

    it 'is not sent if state set to created' do
      expect(subject).not_to receive(:delay)
      subject.update!(location: 'Bern', state: 'created')
    end

    it 'is not sent if state set to nil' do
      expect(subject).not_to receive(:delay)
      subject.update!(location: 'Bern', state: nil)
    end

    it 'is not sent if state set to assignment_closed' do
      expect(subject).not_to receive(:delay)
      subject.update!(location: 'Bern', state: 'assignment_closed')
    end

    it 'is not sent to freshly assigned if state is created' do
      subject.update!(state: 'created')
      expect(subject).not_to receive(:delay)
      subject.update!(location: 'Bern', abteilungsleitung_id: people(:al_schekka).id, coach_id: people(:al_schekka).id)
    end

    it 'is sent to assigned if state changed from nil to assignment_closed' do
      subject.update!(state: nil)
      delay = double('delay')
      expect(Event::CampMailer).to receive(:delay).and_return(delay).twice
      expect(delay).to receive(:advisor_assigned).with(subject, people(:al_berchtold), :coach, nil)
      expect(delay).to receive(:advisor_assigned).with(subject, people(:bulei), :advisor_snow_security, nil)
      subject.update!(location: 'Bern', state: 'assignment_closed')
    end

    it 'is sent to assigned if state changed from created to confirmed' do
      subject.update!(state: 'created')
      delay = double('delay')
      expect(Event::CampMailer).to receive(:delay).and_return(delay).exactly(3).times
      expect(delay).to receive(:advisor_assigned).with(subject, people(:al_berchtold), :coach, nil)
      expect(delay).to receive(:advisor_assigned).with(subject, people(:bulei), :advisor_snow_security, nil)
      expect(delay).to receive(:advisor_assigned).with(subject, people(:al_schekka), :abteilungsleitung, nil)
      subject.update!(location: 'Bern', state: 'confirmed', abteilungsleitung_id: people(:al_schekka).id)
    end

    it 'is sent to freshly assigned' do
      delay = double('delay')
      expect(Event::CampMailer).to receive(:delay).and_return(delay).exactly(2).times
      expect(delay).to receive(:advisor_assigned).with(subject, people(:al_schekka), :abteilungsleitung, nil)
      expect(delay).to receive(:advisor_assigned).with(subject, people(:al_schekka), :coach, nil)
      subject.update!(location: 'Bern',
                      abteilungsleitung_id: people(:al_schekka).id,
                      coach_id: people(:al_schekka).id,
                      advisor_snow_security_id: nil)
    end
  end

end
