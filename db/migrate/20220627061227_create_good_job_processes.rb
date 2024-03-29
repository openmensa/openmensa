# frozen_string_literal: true

class CreateGoodJobProcesses < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.table_exists?(:good_job_processes)
      end
    end

    create_table :good_job_processes, id: :uuid do |t|
      t.timestamps
      t.jsonb :state
    end
  end
end
