# frozen_string_literal: true

release_file = Rails.root.join('REVISION')
if release_file.exist?
  REVISION = File.read(release_file).to_s
else
  REVISION = false
end
