#  Copyright (c) 2019, Pfadibewegung Schweiz This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Pbs::EventSerializer do
  let(:camp) { Fabricate(:pbs_camp) }
  let(:serializer) { EventSerializer.new(camp)}
  subject(:serialized) { serializer.to_hash }

  it { is_expected.to eq({ id: camp.id, href: event_url(item.id, format: :json) }) }
end
