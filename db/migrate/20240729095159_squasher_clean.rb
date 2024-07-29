# frozen_string_literal: true

class SquasherClean < ActiveRecord::Migration[7.1]
  class SchemaMigration < ActiveRecord::Base
  end

  def up
    migrations = Dir.glob(File.join(File.dirname(__FILE__), "*.rb"))
    versions = migrations.map {|file| File.basename(file)[/\A\d+/] }
    SchemaMigration.where.not(version: versions).delete_all
  end

  def down; end
end
