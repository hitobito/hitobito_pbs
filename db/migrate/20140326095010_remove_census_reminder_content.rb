class RemoveCensusReminderContent < ActiveRecord::Migration
  def change
    CustomContent.where(key: 'census_reminder').destroy_all
  end
end
