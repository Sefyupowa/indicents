#!/usr/bin/bash 
####################################
# Script not finished, used for POC only
#
####################################
# Resolve the OTP before changing curl/path behavior for EST calls.
#Set the variables
#in case of gitbash windows, disable path conversion to avoid issues with curl and openssl commands
export MSYS_NO_PATHCONV=1
curlPath="/c/Progs/curl-8.8.0_2-win64-mingw/bin"   #TOBE set to the path of curl, or comment the line if curl is up to date. 
export PATH=$curlPath:$PATH      # comment if curl is up to date. 

which curl


#########################################################################
url="https://protocol.clm-pp-pki.corp.intraxa"  #TOBE set
profile="pp1-est-systemauth"  #TOBE set
#########################################################################


csr_path="$(hostname).csr"
cert_path="$(hostname).crt"
cert_path_fullchain="$(hostname).fullchain.crt"
private_key_path="$(hostname).key"
chain_path="$(hostname).chain.crt"
cacertEndpoint=$url/.well-known/est/$profile/cacerts
enrollEndpoint=$url/.well-known/est/$profile/simpleenroll
reenrollEndpoint=$url/.well-known/est/$profile/simplereenroll
curlcmd="curl -s -k"




##otp="$(printf '%s' "$otp_response" | jq -r '.password.value // empty' | tr -d '\r\n')"
otp="S54jX9HTcweHagH4"


if [ -z "$otp" ]; then
  echo "Failed to fetch OTP. Response: $otp_response"
  exit 1
fi



print_green() {
  local message="$1"
  echo -e "\e[32m${message}\e[0m"
}

print_red() {
  local message="$1"
  echo -e "\e[31m${message}\e[0m"
}

print_green "OTP fetched"
echo $otp



print_green "Fetching CA chain from EST server:"
ca_chain_pem="$(${curlcmd} --url "${cacertEndpoint}" | openssl base64 -d| openssl pkcs7 -inform DER -outform PEM -print_certs | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' )"
root_ca="${ca_chain_pem%%-----END CERTIFICATE-----*}-----END CERTIFICATE-----"
intermediate_ca=$(echo -e "${ca_chain_pem#*-----END CERTIFICATE-----}" | sed '/./,$!d')

print_green "Root + sub CA certificate:"
echo -e "${root_ca}\n${intermediate_ca}" 
echo -e "${root_ca}\n${intermediate_ca}" > "${chain_path}"

print_green "generating private key and CSR ..."

openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout "${private_key_path}" -out "${csr_path}" -subj "/emailAddress=webmaster@example.com/CN=$(hostname)"

print_green "enrolling certificate with EST server ..."
server_cert="$(${curlcmd}   -X  POST ${enrollEndpoint}  --anyauth -u ${profile}:${otp}  --data-binary "@${csr_path}" --cacert "${root_ca}" -H "Content-Type: application/pkcs10" | openssl base64 -d  | openssl pkcs7 -inform DER -outform PEM -print_certs | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/')"

if [ -z "$server_cert" ]; then
  print_red "Failed to enroll certificate with EST server."
  exit 1
fi

print_green "Server certificate full chain:"
echo -e "${server_cert}\n${intermediate_ca}\n${root_ca}" > "${cert_path_fullchain}"
echo -e "${server_cert}\n${intermediate_ca}\n${root_ca}"

openssl x509 -in "${cert_path_fullchain}"   -noout -serial -fingerprint -issuer -subject -ext subjectAltName