# frozen_string_literal: true

namespace :ci do
  desc 'Setup service for CI'
  task setup: %w[db:create:all db:setup] do
  end

  desc 'Run specs for CI'
  task spec: %w[^spec] do
  end
end
