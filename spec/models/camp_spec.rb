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

end
