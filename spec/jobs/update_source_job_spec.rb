# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdateSourceJob do
  subject(:perform) do
    UpdateSourceJob.perform_now(source)
  end

  let(:source) { create(:source, **options) }
  let(:updater) { instance_double(OpenMensa::SourceUpdater) }
  let(:options) { {} }

  before do
    allow(OpenMensa::SourceUpdater).to receive(:new).with(source).and_return(updater)
  end

  context "without meta URL" do
    let(:options) { {meta_url: ""} }

    it "does not update the source" do
      expect(updater).not_to receive(:sync)
      perform
    end
  end

  context "with meta URL" do
    let(:options) { {meta_url: "http://localhost"} }

    it "does invoke the source updater" do
      expect(updater).to receive(:sync)
      perform
    end

    context "and archived canteen" do
      before do
        source.canteen.update!(state: :archived)
      end

      it "does not update the source" do
        expect(updater).not_to receive(:sync)
        perform
      end
    end
  end
end
