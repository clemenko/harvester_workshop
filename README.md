# harvester_workshop

[config example](https://docs.harvesterhci.io/v1.1/install/harvester-configuration/)


## Cloud Init Template
```bash
#cloud-config
package_update: true
disable_root: false
ssh_pwauth: true
packages:
  - qemu-guest-agent
  - vim
  - sudo
  - epel-release
runcmd:
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service
users:
  - name: root
    hashed_passwd: $6$fgls6Nv/5eS$iozPi2/3f9SE7cR5mvTlriGkRZRSuhzFs0s6fVWzUXiL19E27hVgAo3mZwCdzlDsiUq1YRJeyPtql6FkPhMZP0
    lock_passwd: false
    shell: /bin/bash
  - name: rancher
    hashed_passwd: $6$fgls6Nv/5eS$iozPi2/3f9SE7cR5mvTlriGkRZRSuhzFs0s6fVWzUXiL19E27hVgAo3mZwCdzlDsiUq1YRJeyPtql6FkPhMZP0
    lock_passwd: false
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
```



### harvester cli

https://github.com/belgaied2/harvester-cli
export HARVESTER_CONFIG=/Users/clemenko/Desktop/local.yaml


### ipxe

[https://github.com/harvester/ipxe-examples](https://github.com/harvester/ipxe-examples)

