# == Schema Information
#
# Table name: event_approvals
#
#  id             :integer          not null, primary key
#  application_id :integer          not null
#  layer          :string(255)      not null
#  approved       :boolean          default(FALSE), not null
#  rejected       :boolean          default(FALSE), not null
#  comment        :text
#  approved_at    :datetime
#  approver_id    :integer
#

require 'spec_helper'

describe Event::Approval do

  [ [ 'bund', Group::Bund::Geschaeftsleitung, Group::Bund::LeitungKernaufgabeAusbildung ],
    [ 'kantonalverband', Group::Kantonalverband::Kantonsleitung, Group::Kantonalverband::VerantwortungAusbildung ],
    [ 'region', Group::Region::Regionalleitung, Group::Region::VerantwortungAusbildung ],
    [ 'abteilung', Group::Abteilung::Abteilungsleitung, Group::Abteilung::AbteilungsleitungStv ] ].each do |layer, *roles|

      it "#roles in #{layer} equal #{roles}" do
        expect(Event::Approval.new(layer: layer).roles).to eq Array(roles)
      end
    end


  [ [ 'bund', Group::Bund],
    [ 'kantonalverband', Group::Kantonalverband],
    [ 'region', Group::Region],
    [ 'abteilung', Group::Abteilung] ].each do |layer, layer_class|
      it "#layer_class in #{layer} equal #{layer_class}" do
        expect(Event::Approval.new(layer: layer).layer_class).to eq layer_class
      end
    end

  [ [ { approved: true }, :approved ],
    [ { rejected: true },  :rejected ],
    [ {}, nil ] ].each do |attrs, status|
      it "#status for attributes #{attrs} equals #{status}" do
        expect(Event::Approval.new(attrs).status).to eq status
      end
    end

  def create_approval(layer, role, group_name, attrs = {}, course = events(:top_course))
    person = Fabricate(role.name, group: groups(group_name)).person
    participation = Fabricate(:pbs_participation, event: course, person: person)
    application = participation.create_application!(priority_1: course)
    application.approvals.create!(attrs.merge(layer: layer))
  end

  it '.pending lists all pending approvals of layer in hiearchy' do
    bund = create_approval('bund', Group::Bund::Geschaeftsleitung, :bund)
    chaeib = create_approval('kantonalverband', Group::Abteilung::Praeses, :chaeib)
    patria1 = create_approval('kantonalverband', Group::Abteilung::Praeses, :patria)
    patria2 = create_approval('kantonalverband', Group::Abteilung::Praeses, :patria)

    expect(Event::Approval.pending(groups(:be))).to eq [patria1, patria2]
    expect(Event::Approval.pending(groups(:zh))).to eq [chaeib]
    expect(Event::Approval.pending(groups(:bund))).to eq [bund]
  end

  it '.completed lists only completed approvals for event' do
    approved = create_approval('bund', Group::Bund::Geschaeftsleitung, :bund, { approved: true })
    rejected = create_approval('bund', Group::Bund::Geschaeftsleitung, :bund, { rejected: true })

    other_course = Fabricate(:pbs_course)
    other = create_approval('bund', Group::Bund::Geschaeftsleitung, :bund, { rejected: true }, other_course)

    expect(Event::Approval.completed(events(:top_course))).to eq [approved, rejected]
    expect(Event::Approval.completed(other_course)).to eq [other]
  end
end

