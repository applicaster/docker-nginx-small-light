require "faraday"
require "envyable"
Envyable.load("./config/env.yml", ENV["TEST"])

class Server
  CONTAINER_NAME = "nginx-small-light-test"
  SERVER_IP = `docker-machine ip default`.strip

  attr_accessor :server_port

  extend Forwardable
  def_delegator :connection, :get

  def self.instance
    @server ||= Server.new
  end

  def initialize
    @server_port = (5000 + rand(999))
  end

  def start
    `docker build -t #{CONTAINER_NAME} .`

    `docker kill #{CONTAINER_NAME} 2> /dev/null`
    `docker wait #{CONTAINER_NAME} 2> /dev/null`
    `docker rm  #{CONTAINER_NAME} 2> /dev/null`

    `
      docker run \
        -d \
        --name #{CONTAINER_NAME} \
        -p #{server_port}:80 \
        --env UPSTREAM_BASE_URL=#{ENV["UPSTREAM_BASE_URL"]} \
        #{CONTAINER_NAME}
    `.strip
  end

  def stop
    `docker kill #{CONTAINER_NAME}`.strip
  end

  def wait_for_server_to_start
    Timeout.timeout(10) do
      sleep 0.1 until port_open?
    end
  end

  def port_open?
    connection.get("/health")
    puts "Connected"
    true
  rescue Faraday::ConnectionFailed => e
    puts "Waiting for connection... #{e.message}"
  end

  def connection
    Faraday.new(url: "http://#{SERVER_IP}:#{server_port}") do |faraday|
      # faraday.response :logger
      # faraday.response :raise_error
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
