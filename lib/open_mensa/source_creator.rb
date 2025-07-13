# frozen_string_literal: true

class OpenMensa::SourceCreator < OpenMensa::SourceUpdater
  attr_reader :source

  # 4. all together
  def sync
    return unless fetch! && parse! && validate!

    canteen = create_canteen(extract_canteen_node)
    return if canteen.nil? || !canteen.valid?

    source.canteen = canteen
    source.save

    create_feeds(extract_canteen_node)

    true
  end

  private

  def create_feeds(canteen)
    canteen.element_children.select do |node|
      next unless node.name == "feed"

      create_feed(node)
    end
  end

  def create_canteen(canteen_node)
    canteen = Canteen.new
    extract_metadata(canteen, canteen_node)
    canteen.save
    canteen
  end
end
