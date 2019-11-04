# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventDecorator do

  let(:decorator) { EventDecorator.new(event) }

  context 'used_attributes' do

    subject do
      decorator.used_attributes(:name, :location, :contact_id, :express_fee,
                                :participants_can_apply, :j_s_kind, :advisor_id)
    end

    context 'regular event' do
      let(:event) { Fabricate(:event) }
      it { is_expected.to eq(%w(name location contact_id)) }
    end

    context 'course' do
      let(:event) { Fabricate(:pbs_course) }
      it { is_expected.to eq(%w(name location contact_id express_fee advisor_id)) }
    end

    context 'campy course' do
      let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }
      it { is_expected.to eq(%w(name location contact_id express_fee j_s_kind)) }
    end

    context 'camp' do
      let(:event) { Fabricate(:pbs_camp) }
      it { is_expected.to eq(%w(name location participants_can_apply j_s_kind)) }
    end
  end

  context 'can_have_confirmations?' do

    context 'regular event' do
      let(:event) { Fabricate(:event) }
      it { expect(decorator.can_have_confirmations?).to be_falsey }
    end

    context 'course' do
      let(:event) { Fabricate(:pbs_course) }

      it 'flag not set' do
        expect(decorator.can_have_confirmations?).to be_falsey
      end

      it 'flag set' do
        event.kind.can_have_confirmations = true
        expect(decorator.can_have_confirmations?).to be_truthy
      end
    end

    context 'camp' do
      let(:event) { Fabricate(:pbs_camp) }
      it { expect(decorator.can_have_confirmations?).to be_falsey }
    end

  end

  context 'number of qualified course participants' do

    let!(:role) { Fabricate(Event::Role::Participant.name, participation: participation) }
    let(:participation) { Fabricate(:event_participation, event: event, qualified: true) }

    context 'regular event' do
      let(:event) { Fabricate(:event) }
      it { expect(decorator.qualified_participants_count).to eq(0) }
    end

    context 'course' do
      let(:event) { Fabricate(:pbs_course) }

      before do
        participation.event.kind.update(can_have_confirmations: true,
                                        confirmation_name: 'basiskurs')
      end

      it { expect(decorator.qualified_participants_count).to eq(1) }
    end

    context 'camp' do
      let(:event) { Fabricate(:pbs_camp) }
      it { expect(decorator.qualified_participants_count).to eq(0) }
    end

  end

end
