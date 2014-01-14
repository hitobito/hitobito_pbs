# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

shared_examples 'sub_groups' do
  subject             { assigns(:sub_groups) }
  let(:census_open)   { census.finish_at }
  let(:census_locked) { census.finish_at + 1.day }

  shared_examples 'sub_groups_examples' do
    context 'before deadline' do
      before do
        Date.stub(today: census_open)
        get :index, id: parent.id
      end
      it { should eq before_deadline.sort_by(&:name) }
    end

    context 'after deadline' do
      before do
        Date.stub(today: census_locked)
        get :index, id: parent.id
      end
      it { should eq after_deadline.sort_by(&:name) }
    end

    context 'next year' do
      before { get :index, id: parent.id, year: census.year + 1 }
      it     { should eq next_year.sort_by(&:name) }
    end
  end

  context 'when noop' do
    let(:before_deadline) { subgroups }
    let(:after_deadline)  { subgroups - [group_without_count] }
    let(:next_year)       { subgroups }

    include_examples 'sub_groups_examples'
  end

  context 'when creating new group' do
    let!(:dummy)          { Fabricate(group_to_delete.class.name.to_sym, parent: parent, name: 'Dummy') }
    let(:before_deadline) { subgroups + [dummy] }
    let(:after_deadline)  { subgroups - [group_without_count] } # dummy has no count
    let(:next_year)       { subgroups + [dummy] }

    include_examples 'sub_groups_examples'
  end

  context 'when deleting group' do
    context 'deleting group only' do
      let(:before_deadline) { subgroups - [group_to_delete] }
      let(:after_deadline)  { subgroups - [group_without_count] } # group included as it has count
      let(:next_year)       { subgroups - [group_to_delete] }

      before { delete_group_and_children }

      include_examples 'sub_groups_examples'
    end

    context 'deleting group and member count' do
      let(:before_deadline) { subgroups - [group_to_delete] }
      let(:after_deadline)  { subgroups - [group_to_delete, group_without_count] } # dummy has no count
      let(:next_year)       { subgroups - [group_to_delete] }

      before do
        delete_group_and_children
        delete_group_member_counts
      end

      include_examples 'sub_groups_examples'
    end
  end

  context 'when merging groups' do
    before do
      if group_to_delete.is_a?(Group::Kantonalverband)
        [group_to_delete, group_without_count].each { |g| g.events.destroy_all }
      end

      merger = Group::Merger.new(group_to_delete, group_without_count, 'Dummy')
      merger.merge!.should be_true
      @dummy = merger.new_group
    end

    let(:before_deadline) { subgroups - [group_to_delete, group_without_count] + [@dummy] }
    let(:after_deadline)  { subgroups - [group_without_count]  } # only groups with count
    let(:next_year)       { subgroups - [group_to_delete, group_without_count] + [@dummy] }

    include_examples 'sub_groups_examples'
  end
end

def delete_group_member_counts
  field = "#{group_to_delete.class.model_name.element}_id"
  MemberCount.destroy_all(field => group_to_delete.id)
end

# Group#protect_if :children_without_deleted
# we first delete children, then group and validate return values
def delete_group_and_children(deleted_at = Time.zone.now)
  group_to_delete.update_column(:deleted_at, deleted_at)
  group_to_delete.should be_destroyed
end
