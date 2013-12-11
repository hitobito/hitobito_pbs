
require 'spec_helper'


describe GroupAbility do


  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }


  context 'mitarbeiter gs' do
    let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

    context 'in bund' do
      it 'may modify superior attributes' do
        should be_able_to(:modify_superior, groups(:bund))
      end
    end

    context 'in kanton' do
      it 'may modify superior attributes' do
        should be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may modify superior attributes' do
        should be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end

  context 'kantonsleitung' do
    let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)) }

    context 'in kanton' do
      it 'may not modify superior attributes' do
        should_not be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may not modify superior attributes' do
        should_not be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end
end
