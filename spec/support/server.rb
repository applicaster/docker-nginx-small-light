require "faraday"

class Server
  CONTAINER_NAME = "nginx-small-light-test"
  SERVER_IP =`docker-machine ip default`.strip

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
    `docker build -t nginx-small-light-test .`

    `docker kill #{CONTAINER_NAME} 2> /dev/null`
    `docker wait #{CONTAINER_NAME} 2> /dev/null`
    `docker rm  #{CONTAINER_NAME} 2> /dev/null`

    `
      docker run \
        -d \
        --name #{CONTAINER_NAME} \
        -p #{server_port}:80 \
        --env UPSTREAM_BASE_URL="http://s3.amazonaws.com/assets-production.applicaster.com" \
        nginx-small-light-test
    `
  end

  def stop
    `docker kill #{CONTAINER_NAME}`
  end

  def wait_for_server_to_start
    Timeout.timeout(10) do
      sleep 0.1 while !is_port_open?
    end
  end

  def is_port_open?
    connection.get("/health")
    true
  rescue Faraday::ConnectionFailed
  end

  def connection
    Faraday.new(url: "http://#{SERVER_IP}:#{server_port}") do |faraday|
      # faraday.response :logger
      # faraday.response :raise_error
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
