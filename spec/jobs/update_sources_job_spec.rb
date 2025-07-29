# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdateSourcesJob do
  subject(:jobs) { GoodJob::Job.where(job_class: "UpdateSourceJob") }

  let!(:sources) do
    create_list(:source, 3)
  end

  it "invokes enqueues an update job for all sources" do
    UpdateSourcesJob.perform_now

    sources.each do |source|
      expect(UpdateSourceJob).to have_been_enqueued.with(source)
    end
  end
end
