# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdateParsersJob, type: :job do
  it "invokes OpenMensa::UpdateParsersTask#do" do
    expect_any_instance_of(OpenMensa::UpdateParsersTask).to receive(:do)
    UpdateParsersJob.new.perform
  end
end
