# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdateSourcesJob do
  it "invokes OpenMensa::UpdateSourcesTask#do" do
    expect_any_instance_of(OpenMensa::UpdateSourcesTask).to receive(:do)
    UpdateSourcesJob.new.perform
  end
end
