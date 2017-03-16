require "erb"

def prep_dockerfile
  template = "Dockerfile.erb"
  target = "Dockerfile"
  erb = ERB.new(File.read(template)).result(binding)
  File.write(target, erb)
end

prep_dockerfile
