class MigrateBundesKommissionRoles < ActiveRecord::Migration[4.2]
  def change
    bundes_group_ids = Group.where(type: 'Group::BundesKommission').select(:id)
    bundes_mitglieder = Role.where(type: 'Group::Kommission::Mitglied').where(group_id: bundes_group_ids)
    bundes_leitung = Role.where(type: 'Group::Kommission::Leitung').where(group_id: bundes_group_ids)
    Role.transaction do
      bundes_mitglieder.update_all(type: 'Group::BundesKommission::Mitglied')
      bundes_leitung.update_all(type: 'Group::BundesKommission::Leitung')
    end
  end
end
