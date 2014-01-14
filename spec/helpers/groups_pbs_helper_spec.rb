# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

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
