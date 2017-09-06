# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


require 'spec_helper'

describe 'event/participations/_form.html.haml' do

  let(:participant) { people(:bulei) }
  let(:participation) { event_participations(:top_participant) }
  let(:event) { events(:top_course) }
  let(:group) { event.groups.first }
  let(:dom) { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive_messages(current_user: participant,
                                    path_args: [group, event, participation],
                                    model_class: Event::Participation)

    allow(view).to receive_messages(entry: participation.decorate)
    allow(controller).to receive_messages(current_user: participant)
    assign(:event, event.decorate)
    assign(:group, group)
    assign(:answers, participation.answers)
  end

  it 'includes documents_text in application' do
    event.kind.update_attribute(:documents_text, 'some documents text')
    render
    expect(dom).to have_content 'some documents text'
  end

end
