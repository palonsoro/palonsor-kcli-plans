#!/bin/bash

set -euo pipefail

if ! command -v xq
then
	echo "You need to install kslyuk's yq (https://github.com/kislyuk/yq), not any of the other yq's"
	exit 1
fi

NETWORK="${1}"
VIP="${2}"
HOST="${3:-apps}"

virsh net-destroy "${NETWORK}"

DOMAIN="$(virsh net-dumpxml --inactive "${NETWORK}" | xq -r '.network.domain["@name"]')"

virsh net-dumpxml --inactive "${NETWORK}" | xq -x ".network[\"@xmlns:dnsmasq\"]=\"http://libvirt.org/schemas/network/dnsmasq/1.0\"|.network[\"dnsmasq:options\"]={\"dnsmasq:option\":[{\"@value\":\"address=/apps.${DOMAIN}/${VIP}\"}]}" | virsh net-define /dev/stdin

virsh net-start "${NETWORK}"
