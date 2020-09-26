#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe TokenAbility do

  subject { ability }
  let(:ability) { TokenAbility.new(token) }

  describe :group_health do
    let(:token) { service_tokens(:rejected_top_group_token) }

    context 'not allowed' do

      before do
        token.update(layer: groups(:zh), group_health: true)
      end

      it 'may not be created' do
        expect(token).to_not be_valid
        expect(token.errors[:group_health]).to eq ['darf nicht ausgefüllt werden']
      end
    end

    context 'authorized' do

      before do
        token.update(group_health: true)
      end

      it 'may show' do
        is_expected.to be_able_to(:show, GroupHealthController)
      end
    end

    context 'unauthorized' do

      it 'may not show' do
        is_expected.not_to be_able_to(:show, GroupHealthController)
      end
    end
  end
end
