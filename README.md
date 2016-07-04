# ngx_small_light Docker image

A docker image containing Nginx compiled with ngx_small_light

See `Makefile` for tasks.

## Testing
```bash
  make test
```

Testing with a local dockerized http server using docker-compose. The compose file is dynamically generated using ERB to include docker-machine ip and random server ports. Run the tests once to generate your compose file.
