class AddLastReportAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_report_at, :datetime, default: nil
  end
end
