#/bin/bash
set -e
set -x

# master_dns="master_dns"
# k8s_service_ip="k8s_service_ip"
# ips="pub_ip1,pub_ip2,pub_ip3,priv_ip1,priv_ip2,priv_ip3"
# dns="pub_dns1,pub_dns2,pub_dns3,priv_dns1,priv_dns2,priv_dns3"

IPS="${ips}"
DNS="${dns}"

cat <<MYEOF > tls-assets/openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
MYEOF

BASE=3
if [[ "${master_dns}" != "" ]]; then
	echo "DNS.3 = ${master_dns}"
	BASE=$(($BASE+1))
fi

IFS=',' read -ra VARS <<< "${dns}"
for i in "$${!VARS[@]}"; do
	LEN=$${#VARS[@]}
	echo "DNS.$(($i + $BASE)) = $${VARS[$i]}" >> tls-assets/openssl.cnf
done

echo "IP.1 = ${k8s_service_ip}" >> tls-assets/openssl.cnf

BASE=2
IFS=',' read -ra VARS <<< "${ips}"
for i in "$${!VARS[@]}"; do
	LEN=$${#VARS[@]}
	echo "IP.$(($i + $BASE)) = $${VARS[$i]}" >> tls-assets/openssl.cnf
done
