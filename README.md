# ngx_small_light Docker image

A docker image containing Nginx compiled with ngx_small_light

See `Makefile` for tasks.

## Testing
```bash
  make test
```

Testing with a local dockerized http server using docker-compose. The compose file is dynamically generated using ERB to include docker-machine ip and random server ports. Run the tests once to generate your compose file.

## Deploying to production
Deploying this project to production is kind of manual at the moment.
First build the docker image and push it to docker hub with the `production` tag
```bash
  make push_production
```
Terraform knows to pull the image with the `production` tag (as you an see [here](https://github.com/applicaster/terraform-aws/blob/b508728d5ae4ecbd8ec1c91fbe5df60a0087d303/us-east-1/service-images-coreos.tf#L61))


First let's visit the ELBs [version end-point](http://images-coreos-1451002248.us-east-1.elb.amazonaws.com/version) and check the current git sha deployed.

Now we have to get terraform to pull the latest image.
- In AWS console do to the EC2 service and rename the `images-coreos` instances to something you can easily recognize. e.g `images-coreos-1`, `images-coreos-2`
- Go to the `images-coreos` autoscaling group.
- Scale it to double the current amount of instances.
- Once the goup has completely scaled detach the instances you previously renamed.
- Monitor that while strictly working on the new scaled instances there are no issues.

Once the new machines are healthy visit the ELBs [version end-point](http://images-coreos-1451002248.us-east-1.elb.amazonaws.com/version) and if all went well you should now see the new git sha.

Now you can terminate the old machines (The ones that were renamed at the beginning of this process)

- In ECS console filter down to `coreos` and sort by `name`
- Select and terminate
- Remember to dial the health check period back to 300 seconds when you are done

Finally, a manual check that it went well.
- Send an original image to the resizer, e.g. using http://images-coreos-1451002248.us-east-1.elb.amazonaws.com/qa/accounts/119/broadcasters/133/categories/20026/image_assets/6603906/original.jpg
- Now try to resize it by adding the reisze command http://images-coreos-1451002248.us-east-1.elb.amazonaws.com/qa/accounts/119/broadcasters/133/categories/20026/image_assets/6603906/original.jpg?12345&command=resize&width=100&height=300
- You should be able to visually verify it worked
