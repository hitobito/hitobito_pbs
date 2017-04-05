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

end
