# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def human_action(action, default: [], **options)
      default = Array.wrap(default).compact
      default << :"actions.defaults.#{action}"

      case action
        when :index
          default << :"activerecord.models.#{name.underscore}"
          options[:count] ||= 3
        when :show
          default << :"activerecord.models.#{name.underscore}"
          options[:count] ||= 1
      end

      I18n.t(
        "actions.models.#{name.underscore}.#{action}",
        **options,
        default:,
        model: model_name.human(**options)
      )
    end
  end
end
