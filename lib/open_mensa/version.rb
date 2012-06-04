module OpenMensa
  module VERSION

    MAJOR = 0
    MINOR = 1
    PATCH = 0
    STAGE = nil
    LEVEL = nil

    def self.to_s
      version + (stage.present? ? "-#{stage}" : '')
    end

    def self.version
      [MAJOR, MINOR, PATCH].map{|v| v.nil? ? 0 : v }.join '.'
    end

    def self.stage
      [STAGE, LEVEL].join
    end
  end
end
