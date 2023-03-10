#!/bin/bash
# docs https://developer.equinix.com/catalog/metalv1#operation/

# Set token  ` export EQ_TOKEN=XXXX `

echo -n " - building server : "
# Create
ID=$(curl -sX POST https://api.equinix.com/metal/v1/projects/1acc31b0-760a-47b9-abac-0f1d381137a5/devices -H 'x-auth-token: '$EQ_TOKEN -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'content-type: application/json' -H 'Accept-Language: en-US,en;q=0.5' -d '{"facility":"dc13","hostname":"harvester01","plan":"c3.small.x86","operating_system":"custom_ipxe","ipxe_script_url":"https://raw.githubusercontent.com/clemenko/harvester_workshop/main/ipxe/ipxe-install","always_pxe":false,"userdata":"#cloud-config\nscheme_version: 1\ntoken: ilikechicken\nos:\n  hostname: harvester01\n  password: Pa22word\n  ntp_servers:\n  - 0.suse.pool.ntp.org\n  - 1.suse.pool.ntp.org\ninstall:\n  mode: create\n  device: /dev/sda\n  iso_url: https://equinixphilip.s3.amazonaws.com/harvester-v1.1.1-amd64.iso\n  tty: ttyS1,115200n8\n  vip: X.X.X.X\n  vip_mode: static","user_ssh_keys":["710a278b-d429-497b-b274-9abdf0b9cd22"]}' | jq -r '.id')

echo "ID = "$ID
sleep 10

echo -n " - getting ip : "
# get ip
IP=""
until [ ! -z "$IP" ]; do
    IP=$(curl -s https://api.equinix.com/metal/v1/devices/$ID -H 'x-auth-token: '$EQ_TOKEN -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'content-type: application/json' | jq -r '.ip_addresses[0].address')
    sleep 3
done
echo "IP = "$IP

echo " - updating ip"
# Update
curl -sX PUT https://api.equinix.com/metal/v1/devices/$ID -H 'x-auth-token: '$EQ_TOKEN -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'content-type: application/json' -d '{"facility":"dc13","hostname":"harvester01","plan":"c3.small.x86","operating_system":"custom_ipxe","ipxe_script_url":"https://raw.githubusercontent.com/clemenko/harvester_workshop/main/ipxe/ipxe-install","always_pxe":false,"userdata":"#cloud-config\nscheme_version: 1\ntoken: ilikechicken\nos:\n  hostname: harvester01\n  password: Pa22word\n  ntp_servers:\n  - 0.suse.pool.ntp.org\n  - 1.suse.pool.ntp.org\ninstall:\n  mode: create\n  device: /dev/sda\n  iso_url: https://equinixphilip.s3.amazonaws.com/harvester-v1.1.1-amd64.iso\n  tty: ttyS1,115200n8\n  vip: '$IP'\n  vip_mode: static","user_ssh_keys":["710a278b-d429-497b-b274-9abdf0b9cd22"]}' > /dev/null 2>&1


echo -n " - waiting"
until [ "$(curl -sk https://$IP/ping)" == "pong" ]; do 
   echo -n "."
   sleep 5;
done
echo ""

echo " - Done = https://"$IP 
