test:
	bundle exec rspec

build:
	docker build -t nginx-small-light .

run: build
	docker run \
		--rm \
		-it \
		-p 5000:80 \
		--env UPSTREAM_BASE_URL="http://assets-production.applicaster.com.s3.amazonaws.com" \
		nginx-small-light
