require "simplecov"

SimpleCov.start

require "bundler/setup"
require "scallop"

FIXTURES_PATH = File.join(__dir__, "fixtures")

def fixture_path(filename)
  File.join(FIXTURES_PATH, filename).tap do |filepath|
    raise "Fixture doesn't exists: #{filename}" unless File.exists?(filepath)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
