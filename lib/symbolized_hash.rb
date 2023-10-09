# frozen_string_literal: true

module SymbolizedHash
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    hash&.symbolize_keys
  end
end
