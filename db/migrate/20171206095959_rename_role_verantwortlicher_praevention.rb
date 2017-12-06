class RenameRoleVerantwortlicherPraevention < ActiveRecord::Migration
  def change
    say_with_time 'Rename Role Group::Bund::VerantwortungPraeventionSexuellerAusbeutung
     to Group::Bund::VerantwortungPraevention' do
      Role.where(type: 'Group::Bund::VerantwortungPraeventionSexuellerAusbeutung')
            .find_each do |role|
              role.update(type: 'Group::Bund::VerantwortungPraevention')
            end
    end

    say_with_time 'Rename Role Group::Kantonalverband::VerantwortungPraeventionSexuellerAusbeutung
     to Group::Kantonalverband::VerantwortungPraevention' do
      Role.where(type: 'Group::Kantonalverband::VerantwortungPraeventionSexuellerAusbeutung')
            .find_each do |role|
              role.update(type: 'Group::Kantonalverband::VerantwortungPraevention')
            end
    end

    say_with_time 'Rename Role Group::Region::VerantwortungPraeventionSexuellerAusbeutung
     to Group::Region::VerantwortungPraevention' do
      Role.where(type: 'Group::Region::VerantwortungPraeventionSexuellerAusbeutung')
            .find_each do |role|
              role.update(type: 'Group::Region::VerantwortungPraevention')
            end
    end
  end
end
