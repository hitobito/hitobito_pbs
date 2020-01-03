# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


require 'spec_helper'

describe 'event/qualifications/index.html.haml' do

  let(:participation) { event_participations(:top_participant) }
  let(:participant) { participation.person }
  let(:event) { participation.event.decorate }
  let(:dom) { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive(:event).and_return(event)
    assign(:event, event)
    assign(:leaders, [])
    assign(:participants, [])
  end

  context 'confirmations checkbox depends on course kind setting' do

    it 'displays confirmations checkbox' do
      event.kind.update_attributes(can_have_confirmations: true, confirmation_name: 'basiskurs')
      render
      expect(dom).to have_content 'PDF-Kursbestätigungen für Teilnehmende erstellen'
    end

    it 'does not display confirmations checkbox' do
      event.kind.update_attributes(can_have_confirmations: false)
      render
      expect(dom).not_to have_content 'PDF-Kursbestätigungen für Teilnehmende erstellen'
    end

  end

  context 'confirmation info email button depends on number of qualified participants' do

    before do
      event.kind.update_attributes(can_have_confirmations: true, confirmation_name: 'basiskurs')
      controller.request.path_parameters[:event_id] = event.id
      controller.request.path_parameters[:group_id] = event.groups.first.id
    end

    it 'does not display email button when no participants qualified' do
      allow(event).to receive(:qualified_participants_count).and_return(0)
      render
      expect(dom).not_to have_content 'Personen versenden'
    end

    it 'shows one qualified_participants_count on email button' do
      allow(event).to receive(:qualified_participants_count).and_return(1)
      render
      expect(dom).to have_content 'Benachrichtigung an eine Person versenden'
    end

    it 'shows multiple qualified_participants_count on email button' do
      allow(event).to receive(:qualified_participants_count).and_return(2)
      render
      expect(dom).to have_content 'Benachrichtigungen an 2 Personen versenden'
    end

  end

end
