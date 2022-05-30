# frozen_string_literal: true

require "spec_helper"

RSpec.describe DailyReportsJob, type: :job do
  it "invokes OpenMensa::DailyReportTask#do" do
    expect_any_instance_of(OpenMensa::DailyReportTask).to receive(:do)
    DailyReportsJob.new.perform
  end
end
