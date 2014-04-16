#
# Studix Guardfile -- for RSpec
#

guard 'rspec', cli: '--drb' do
  watch(%r{^spec/(.+)_spec\.rb$})                     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/factories/(.+)\.rb$})                { |m| "spec" }
  watch(%r{^spec/factories.rb})                       { "spec" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  # Capybara request specs
  watch(%r{^spec/requests/(.+).rb})                   { |m| "spec/requests/#{m[1]}.rb" }
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
  watch(%r{^app/views/api/(.+)/.*\.(erb|rabl)$})      { |m| ["spec/requests/api", "spec/controllers/api"] }
  watch(%r{^app/locales/(.+)/.*$})                    { |m| "spec/requests" }
end

# load Guardfile.local
local_guardfile = File.dirname(__FILE__) + "/Guardfile.local"
if File.file?(local_guardfile)
  self.instance_eval(Bundler.read_file(local_guardfile))
end
