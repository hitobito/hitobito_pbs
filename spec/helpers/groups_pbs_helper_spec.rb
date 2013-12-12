require 'spec_helper'

describe GroupsPbsHelper do

  let(:group) { groups(:schekka) }

  context '#format_group_website' do

    subject { format_group_website(group) }

    it 'renders nil if no website' do
      expect(subject).to eq(nil)
    end

    it 'adds http if missing' do
      group.website = 'schekka.ch'
      expect(subject).to eq('<a href="http://schekka.ch" target="_blank">schekka.ch</a>')
    end

    it 'keeps http if present' do
      group.website = 'https://schekka.ch'
      expect(subject).to eq('<a href="https://schekka.ch" target="_blank">https://schekka.ch</a>')
    end
  end

end
