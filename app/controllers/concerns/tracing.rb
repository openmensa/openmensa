# frozen_string_literal: true

module Tracing
  extend ActiveSupport::Concern

  def with_span(name, **, &)
    Sentry.with_child_span(op: name, **, &)
  end
end
