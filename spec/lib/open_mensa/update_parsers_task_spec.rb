require 'spec_helper'

describe OpenMensa::UpdateParsersTask do
  let(:task) { described_class.new }
  let(:parsers) { FactoryBot.create_list :parser, 3, index_url: 'http://example.org/index.josn' }
  let(:updater) { double('ParserUpdater', sync: true) }

  context '#do' do
    it 'should sync every parser' do
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[0]).and_return(updater)
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[1]).and_return(updater)
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[2]).and_return(updater)

      task.do
    end

    it 'should skip every parser without index_url' do
      parsers[1].update_attributes index_url: nil
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[0]).and_return(updater)
      expect(OpenMensa::ParserUpdater).to_not receive(:new).with(parsers[1])
      expect(OpenMensa::ParserUpdater).to receive(:new).with(parsers[2]).and_return(updater)

      task.do
    end
  end
end
