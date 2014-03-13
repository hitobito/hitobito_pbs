require 'spec_helper'
describe Role do

  let(:role) { roles(:al_schekka) }


  describe 'dates' do
    let(:now) { Time.zone.parse('2014-05-03 16:32:21') }

    before do
      Time.zone.stub(now: now)
      role.update_column(:created_at, '2014-04-03 12:00:00')
    end


    context 'are valid if' do
      it 'created_at in the past' do
        role.should be_valid
      end

      it 'created_at after deleted_at in the past' do
        role.update_column(:deleted_at, '2014-04-03 14:00:00')
        role.should be_valid
      end
    end


    context 'are not valid if' do
      [:created_at, :deleted_at].each do |field|
        it "#{field} in future" do
          role.update_column(field, '2014-05-03 17:00:00')
          role.should_not be_valid
          role.should have(1).error_on(field)
        end
      end

      it 'created_at after deleted_at' do
        role.update_column(:deleted_at, '2014-04-03 11:00:00')
        role.should_not be_valid
        role.should have(1).error_on(:deleted_at)
      end
    end
  end

end
