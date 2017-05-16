class AddLastReportAtToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_report_at, :datetime, default: nil
  end
end
