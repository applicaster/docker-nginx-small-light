require "faraday"
require "yaml"
require "erb"

class Server
  CONTAINER_NAME = "nginx-small-light-test".freeze

  attr_accessor :server_port

  extend Forwardable
  def_delegator :connection, :get

  def self.instance
    @server ||= Server.new
  end

  def initialize
    @server_ip = server_ip
    @server_port = (5000 + rand(999))
    @images_port = (3000 + rand(999))
    @server_ip ||= server_ip
  end

  def start
    prep_docker_compose_file
    prep_dockerfile
    `docker-compose up --build -d`.strip
  end

  def stop
    `docker-compose stop`.strip
  end

  def wait_for_server_to_start
    Timeout.timeout(10) do
      begin
        sleep 0.1 until port_open?
      rescue Faraday::ConnectionFailed => e
        puts "Waiting for connection... #{e.message}"
      end
    end
    sleep 0.1
  end

  def port_open?
    connection.get("/health")
    puts "Connected"
    true
  end

  def connection
    Faraday.new(url: "http://#{@server_ip}:#{server_port}") do |faraday|
      # faraday.response :logger
      # faraday.response :raise_error
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def prep_docker_compose_file
    template = "docker-compose.yml.erb"
    target = "docker-compose.yml"
    yaml = YAML.load(ERB.new(File.read(template)).result(binding).to_yaml)
    File.write(target, yaml)
  end

  def docker_machine_exists?
    system("docker-machine -v")
  end

  def docker_machine_ip
    `docker-machine ip default`.strip
  end

  def linux_docker_ip
    aux = `ip addr show docker0`.split
    aux[aux.index("inet") + 1].split("/").first.strip
  end

  def server_ip
    docker_machine_exists? ? docker_machine_ip : linux_docker_ip
  end

  def prep_dockerfile
    template = "Dockerfile.erb"
    target = "Dockerfile"
    erb = ERB.new(File.read(template)).result(binding)
    File.write(target, erb)
  end
end
