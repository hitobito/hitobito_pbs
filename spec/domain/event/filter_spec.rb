# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Filter do
  let(:be)   { groups(:be) }
  let(:camp) { events(:schekka_camp) }
  subject    { Event::Filter.new(be, 'Event::Camp', filter, 2012, nil).scope }

  before do
    KantonalverbandCanton.create!(kantonalverband: be, canton: 'be')
    expect(be.reload.cantons).to eq ['be']
  end

  context 'filter all' do
    let(:filter) { nil }

    context 'be' do
      let(:group) { be }

      it 'lists camp' do
        expect(subject).to eq [camp]
      end
    end
  end

  context 'filter canton' do
    let(:filter) { 'canton' }

    context 'be' do
      let(:group) { be }

      it 'does not list camp' do
        expect(subject).to eq []
      end

      context 'camp is assigned to be' do
        before { camp.update(canton: 'be') }

        it 'lists camp' do
          expect(subject).to eq [camp]
        end

        it 'lists camp even if assigned to different kantonalverband' do
          camp.update(groups: [groups(:zh)])
          expect(subject).to eq [camp]
        end
      end
    end
  end
end
