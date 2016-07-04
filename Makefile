UPSTREAM_BASE_URL=http://assets-production.applicaster.com.s3.amazonaws.com

test:
	bundle exec rubocop && bundle exec rspec

build:
	docker build -t nginx-small-light .

run: build
	docker run \
		--name nginx-small-light \
		--rm \
		-it \
		-p 5000:80 \
		--env UPSTREAM_BASE_URL="$(UPSTREAM_BASE_URL)" \
		nginx-small-light
