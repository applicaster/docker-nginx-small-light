UPSTREAM_BASE_URL=http://assets-production.applicaster.com.s3.amazonaws.com
CONTAINER_NAME=docker-nginx-small-light

test: create_docker_net build
	bundle exec rubocop && bundle exec rspec
	docker network rm nginx_small_light 

create_docker_net: build
	docker network create --subnet 192.168.33.0/24 --gateway 192.168.33.1 nginx_small_light


build:
	ruby prepare_dockerfile.rb
	docker build -t "applicaster/$(CONTAINER_NAME)" .

run: build
	docker run \
		--name "$(CONTAINER_NAME)" \
		--rm \
		-it \
		-p 5000:80 \
		--env UPSTREAM_BASE_URL="$(UPSTREAM_BASE_URL)" \
		"applicaster/$(CONTAINER_NAME)"

push: build
	docker push "applicaster/$(CONTAINER_NAME)"

push_production:
	ruby prepare_dockerfile.rb
	docker build -t "applicaster/$(CONTAINER_NAME):production" .
	docker push "applicaster/$(CONTAINER_NAME):production"
