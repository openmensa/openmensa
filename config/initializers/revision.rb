# frozen_string_literal: true

release_file = Rails.root.join("REVISION")
REVISION = if release_file.exist?
             File.read(release_file).to_s
           else
             false
           end
