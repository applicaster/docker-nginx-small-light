require "spec_helper"
require "pry"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include ServerHelpers

  config.before(:suite) do
    puts "Starting server..."
    Server.instance.start
    puts "Waiting for server to start..."
    Server.instance.wait_for_server_to_start
  end

  config.after(:suite) do
    Server.instance.stop
  end
end
