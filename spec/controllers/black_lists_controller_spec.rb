require 'spec_helper'

describe BlackListsController do

  let(:person) { Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)).person }
  before { sign_in(person) }

  context 'custom attributes' do
    let(:black_list) { assigns(:black_list) }

    it 'POST#create' do
      post :create, black_list: { first_name: 'foo',
                                  last_name: 'bar',
                                  email: 'foo@bar.com',
                                  pbs_number: '000-001-002',
                                  phone_number: '031 123 12 12',
                                  reference_name: 'Reference',
                                  reference_phone_number: '031 123 45 67' }

      expect(black_list.errors.full_messages).to eq []
      expect(black_list.first_name).to eq 'foo'
      expect(black_list.last_name).to eq 'bar'
      expect(black_list.email).to eq 'foo@bar.com'
      expect(black_list.pbs_number).to eq '000-001-002'
      expect(black_list.phone_number).to eq '031 123 12 12'
      expect(black_list.reference_name).to eq 'Reference'
      expect(black_list.reference_phone_number).to eq '031 123 45 67'
    end

  end
end
