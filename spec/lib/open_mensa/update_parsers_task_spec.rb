# frozen_string_literal: true

require "spec_helper"

describe OpenMensa::UpdateParsersTask do
  let(:task) { described_class.new }
  let(:parsers) { create_list :parser, 3, index_url: "http://example.org/index.josn" }
  let(:updater) { double("ParserUpdater", sync: true) }

  describe "#do" do
    it "syncs every parser" do
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[0]).and_return(updater)
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[1]).and_return(updater)
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[2]).and_return(updater)

      task.do
    end

    it "skips every parser without index_url" do
      parsers[1].update index_url: nil
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[0]).and_return(updater)
      expect(OpenMensa::ParserUpdater).not_to receive(:new).with(parsers[1])
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[2]).and_return(updater)

      task.do
    end
  end
end
