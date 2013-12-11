require 'spec_helper'

describe Person do

  let(:person)     { people(:bulei) }

  context 'validation' do
    it 'succeeds for available' do
      person.salutation = Salutation.available.keys.sample
      expect(person).to be_valid
    end

    it 'succeeds for empty' do
      person.salutation = ' '
      expect(person).to be_valid
    end

    it 'fails for non-available' do
      person.salutation = 'ahoi'
      expect(person).to have(1).error_on(:salutation)
    end
  end

  context '#salutation_value' do
    it 'is correct' do
      expect(person.salutation_value).to eq('Sehr geehrter Herr Dr. Leiter')
    end

    it 'is nil without salutation' do
      person.salutation = nil
      expect(person.salutation_value).to be_nil
    end
  end

  context '#salutation_label' do
    it 'is correct' do
      expect(person.salutation_label).to eq('Sehr geehrte(r) Frau/Herr [Titel] [Nachname]')
    end

    it 'is nil without salutation' do
      person.salutation = nil
      expect(person.salutation_label).to be_nil
    end
  end
end

