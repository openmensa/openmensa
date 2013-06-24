class CreateMailNotifications < ActiveRecord::Migration
  def change
    create_table :mail_notifications do |t|
      t.references :user

      t.timestamps
    end
  end
end
