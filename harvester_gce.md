# square peg --> round hole

## cloud init for harverster install

```yaml
scheme_version: 1
token: ilikechicken
os:
  hostname: harvester01
  ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA26evmemRbhTtjV9szD9SwcFW9VOD38jDuJmyYYdqoqIltDkpUqDa/V1jxLSyrizhOHrlJtUOj790cxrvInaBNP7nHIO+GwC9VH8wFi4KG/TFj3K8SfNZ24QoUY12rLiHR6hRxcT4aUGnqFHGv2WTqsW2sxz03z+W1qeMqWYJOUfkqKKs2jiz42U+0Kp9BxsFBlai/WAXrQsYC8CcpQSRKdggOMQf04CqqhXzt5Q4Cmago+Fr7HcvEnPDAaNcVtfS5DYLERcX2OVgWT3RBWhDIjD8vYCMBBCy2QUrc4ZhKZfkF9aemjnKLfLcbdpMfb+r7NwJsVQSPKcjYAJOckE8RQ== clemenko@clemenko.local
  password: Pa22word
  ntp_servers:
  - 0.suse.pool.ntp.org
  - 1.suse.pool.ntp.org
install:
  mode: create
  device: /dev/sdb
  tty: ttyS0
  vip: X.X.X.X
  vip_mode: static
```

## GCE procedure

```bash
# create blank disk
DISK_NAME=harvester
gcloud compute disks create $DISK_NAME --size=10GB --zone=$(gcloud config get-value compute/zone)

# create vm instance to copy the iso
gcloud compute instances create rocky-temp --project=robust-charge-98613 --zone=us-east4-a --machine-type=e2-medium --metadata=serial-port-enable=true,startup-script=\#\!\ /bin/bash$'\n'\ \ sudo\ yum\ install\ -y\ wget$'\n'\ \ wget\ https://releases.rancher.com/harvester/v1.1.1/harvester-v1.1.1-amd64.iso$'\n'\ \ sudo\ dd\ if=/harvester-v1.1.1-amd64.iso\ of=/dev/sdb\ bs=1024k\ status=progress$'\n'touch\ \~clemenko/dd_done --create-disk=auto-delete=yes,boot=yes,device-name=rocky-temp,image=projects/rocky-linux-cloud/global/images/rocky-linux-9-optimized-gcp-v20230203,mode=rw,size=40,type=projects/robust-charge-98613/zones/us-east4-a/diskTypes/pd-balanced --disk=boot=no,device-name=harvester,mode=rw,name=harvester --no-shielded-secure-boot --no-shielded-vtpm

# what runs in the rocky vm
 # yum install -y wget  && wget https://releases.rancher.com/harvester/v1.1.1/harvester-v1.1.1-amd64.iso && dd if=harvester-v1.1.1-amd64.iso of=/dev/sdb bs=1024k status=progress

# wait until done
# ssh $(gcloud compute instances list | grep RUN | awk '{print $5}') ls /
while true; do clear; ssh $(gcloud compute instances list | grep RUN | awk '{print $5}') 'ls /dd_done'; sleep 5; done

# shutdown and delete vm
gcloud compute instances delete rocky-temp --zone=$(gcloud config get-value compute/zone) --quiet

# share disk --> image
gcloud compute images create $DISK_NAME --source-disk=$DISK_NAME --source-disk-zone=$(gcloud config get-value compute/zone)

# delete disk
gcloud compute disks delete $DISK_NAME --zone=$(gcloud config get-value compute/zone) --quiet

# deploy instance
# serial notes - https://cloud.google.com/compute/docs/troubleshooting/troubleshooting-using-serial-console

gcloud compute instances create harvester-1 --project=robust-charge-98613 --zone=us-east4-a --machine-type=e2-standard-16 --network-interface=network-tier=PREMIUM,subnet=default --metadata=^,@^serial-port-enable=true,@user-data=scheme_version:\ 1$'\n'token:\ ilikechicken$'\n'os:$'\n'\ \ hostname:\ harvester01$'\n'\ \ ssh_authorized_keys:$'\n'\ \ -\ ssh-rsa\ AAAAB3NzaC1yc2EAAAABIwAAAQEA26evmemRbhTtjV9szD9SwcFW9VOD38jDuJmyYYdqoqIltDkpUqDa/V1jxLSyrizhOHrlJtUOj790cxrvInaBNP7nHIO\+GwC9VH8wFi4KG/TFj3K8SfNZ24QoUY12rLiHR6hRxcT4aUGnqFHGv2WTqsW2sxz03z\+W1qeMqWYJOUfkqKKs2jiz42U\+0Kp9BxsFBlai/WAXrQsYC8CcpQSRKdggOMQf04CqqhXzt5Q4Cmago\+Fr7HcvEnPDAaNcVtfS5DYLERcX2OVgWT3RBWhDIjD8vYCMBBCy2QUrc4ZhKZfkF9aemjnKLfLcbdpMfb\+r7NwJsVQSPKcjYAJOckE8RQ==\ clemenko@clemenko.local$'\n'\ \ password:\ Pa22word$'\n'\ \ ntp_servers:$'\n'\ \ -\ 0.suse.pool.ntp.org$'\n'\ \ -\ 1.suse.pool.ntp.org$'\n'install:$'\n'\ \ mode:\ create$'\n'\ \ device:\ /dev/sdb$'\n'\ \ tty:\ ttyS0,115200$'\n'\ \ vip:\ X.X.X.X$'\n'\ \ vip_mode:\ static --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=811525052454-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --enable-display-device --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=harvesterboot,image=projects/robust-charge-98613/global/images/harvester,mode=rw,size=10,type=projects/robust-charge-98613/zones/us-east4-a/diskTypes/pd-balanced --create-disk=device-name=harvesterdata,mode=rw,name=harvesterdata,size=175,type=projects/robust-charge-98613/zones/us-east4-a/diskTypes/pd-balanced --enable-nested-virtualization


# run the installer from the console
# username rancher / password rancher
# resize term
setterm --resize

# run installer
/usr/bin/start-installer.sh 
```

after the reboot remove the boot disk. And boot from the secondary disk "harvesterdata". all I see is a black screen. No ouput. 

```bash
# clean up
gcloud compute instances delete harvester-1 --zone=$(gcloud config get-value compute/zone) --quiet

# remove image
gcloud compute images delete $DISK_NAME --quiet

```

### notes
```bash
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/foo -H "Metadata-Flavor: Google"


gcloud compute instances tail-serial-port-output harvester-1 --zone=$(gcloud config get-value compute/zone)

gcloud compute connect-to-serial-port harvester-1

mkisofs -o harv.iso -b boot/x86_64/loader/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "harv" .
```
