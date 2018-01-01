#cloud-config

ssh_authorized_keys:
  - "ssh-dss AAAAB3NzaC1kc3MAAACBAJaaBKpTayNIMkZZS+BpQxAeOF21AgJqO2oCmCoC86Yz3dOvGneIMOM2L48NDxmEq+J7gwlIZZP/yBAzw+K5cpoXXrnoi/0+XiJI52JSiV6/JrrvNLbZkiVhDqYbamuVtmr1531GjlNoyjxNKGswNUDfkKnJKNAkFmbQWo4Lnla/AAAAFQDwAHKJD+UbaCjZZgGLHj7QXnS5mQAAAIBobctxKo0UHwq/5zR65od7tOSwB4r4PoVMDnc5+zVTiguR323eG1/JbuFdSuK1fk7TlWNoWAg11Plc9J3LHBfNPFikn7b6k2qxcppq8l3yFEGFgiCr1s0Bn0q4Exr022j7gPJdR4bX+oHvJuoPB/9HHm5Zgu8V4ACPYvCc9ydo5AAAAIBkg5TZXV5FtE+hUomXwXfYx+maz08JVdv6yRJXy1lwWxbi7G6vofKNA/PUU2USHmzofAcPsO4MDR2Vx4RYnHMnGUoCIwTwPm1TA6NbKD+IJHsMPI9CnyLHPOMpN/qyMpSWS57Miel9A7iKgyrzIs+3tEM4GHlBaeaD0ryYcp3NFg== neerfri@gmail.com"
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD9ZXbVKKuRgRWa9FiDN9HfzwHFOu6BOHfr4pOBalR+DhFgDTF41Z14YWgF0pn+Cp2Y3aHRuX7ZUnY0UasAgAEnKuTXRcnrx2c39Dl/0jfgAmTZXGZVhvmfMhOwnDW0I3yIgcJHO4nQvpTL0e6n2FNPGWB7B+O4sQVmlc+tamnKPEjiC9Pcy5bL0oLKiQbUSiW0Xt2Y+FzHnv/GqUwWCQd7tM5KzsL1lS0GGx8LyYueqXdT+GIbraKZa0CaLJB7gvruc2bj1HeCAjivja1z6Hh9bCujlE3Ep8n45SYqbkg3iQ0f6wWM/J3Po/hbXKRI8/8P5/2pRic4pZPlRkT8nvi9CLkJ8c9oRxdhjGKVA61DjE8glGDvn6Z6SjM0K7le4Iqm8S++WlmTnYd0SAy3mF3jRO33DTAG5W/Z8dxv64kLqynkt5VXtoVY3+t4nDTnNT1z+AUu+qkb6ImYPKkRzOnP3A2TZUn8scCYKkbiupP8G2uvi8OJ/UCWWZNODc5NtJSpARvC9QLQzf6eS8FzCx9Ia7E1iipef3ToL7i4tpyM3HH+U4JQxMS8zmiFM6FJzxADyrlUYALYyFqfhU778ERZiAU3B9YlF5wLC5m1vOgkekoA++GB3Q6VtP6H7DR75dvCEiP8SybbexBVqvQp0kxKkA4WNeyQ0X/wgB6RHMMoTQ== a.shomer@applicaster.com"
coreos:
  units:
    - name: "nginx-small-light.service"
      command: "start"
      content: |
        [Unit]
        Description=Nginx with ngx_small_light container
        After=docker.service

        [Service]
        Environment=IMAGE_NAME=${image_name}
        Environment=CONTAINER_NAME=nginx-small-light
        Environment=UPSTREAM_BASE_URL=${upstream_base_url}

        Restart=always
        TimeoutStartSec=0

        ExecStartPre=-/usr/bin/docker stop $${CONTAINER_NAME} 2> /dev/null || true
        ExecStartPre=-/usr/bin/docker rm $${CONTAINER_NAME}  2> /dev/null || true
        ExecStartPre=/usr/bin/docker pull $${IMAGE_NAME}

        ExecStart=/usr/bin/docker run \
                    --name $${CONTAINER_NAME} \
                    -p 80:80 \
                    --env UPSTREAM_BASE_URL=$${UPSTREAM_BASE_URL} \
                    $${IMAGE_NAME}
        ExecStop=/usr/bin/docker stop -t 2 $${CONTAINER_NAME}

        [Install]
        WantedBy=multi-user.target
    - name: "nrsysmond.service"
      command: "start"
      content: |
        [Unit]
        Description=New Relic System Monitor (nrsysmond)
        After=docker.service
        Requires=docker.service

        [Service]
        Restart=always
        TimeoutStartSec=10m
        ExecStartPre=-/usr/bin/docker kill nrsysmond
        ExecStartPre=-/usr/bin/docker rm nrsysmond
        ExecStartPre=/usr/bin/docker pull newrelic/nrsysmond
        ExecStart=/usr/bin/docker run \
                    --name nrsysmond \
                    --rm \
                    --pid=host \
                    --privileged=true \
                    --net=host \
                    -v /sys:/sys \
                    -v /dev:/dev \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v /var/log:/var/log \
                    -e NRSYSMOND_license_key=${new_relic_license_key} \
                    -e NRSYSMOND_loglevel=info \
                    -e NRSYSMOND_logfile=/dev/stderr \
                    -e NRSYSMOND_labels=Application:images \
                    -e NRSYSMOND_hostname=%H \
                    newrelic/nrsysmond:latest
        ExecStop=/usr/bin/docker stop -t 30 nrsysmond

        [Install]
        WantedBy=multi-user.target
