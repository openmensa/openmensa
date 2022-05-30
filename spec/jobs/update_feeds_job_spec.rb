# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdateFeedsJob, type: :job do
  it "invokes OpenMensa::UpdateFeedsTask#do" do
    expect_any_instance_of(OpenMensa::UpdateFeedsTask).to receive(:do)
    UpdateFeedsJob.new.perform
  end
end
