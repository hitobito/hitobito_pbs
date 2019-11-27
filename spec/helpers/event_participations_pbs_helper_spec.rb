# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventParticipationsPbsHelper do

  include Haml::Helpers

  let(:participation) { event_participations(:top_participant).decorate }
  let(:event) { participation.event }
  let(:kind) { event.kind }

  context '#course_confirmation_link' do

    let(:subject) { course_confirmation_link(participation) { 'submit button' } }

    before do
      event.update(location: "Line 1\nLine 2")
      kind.update(can_have_confirmations: true)
      participation.update(qualified: true)
    end

    it 'multiline values in hidden fields are escaped and not indented' do
      is_expected.to match(/value="Line 1&#x000A;Line 2"/)
    end

  end

end
