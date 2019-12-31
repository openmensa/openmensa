# frozen_string_literal: true

module Squeel
  module Adapters
    module ActiveRecord
      module RelationExtensions

        def execute_grouped_calculation(operation, column_name, distinct)
          # FIXME: hotfix for https://github.com/activerecord-hackery/squeel/issues/374
          super
        end

      end
    end
  end
end
