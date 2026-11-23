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
profile="pp1-est-serverauth"  #TOBE set
old_cert_path="$(hostname).old.crt"  #path to old certificate to do MTLS
old_key_path="$(hostname).old.key"   #path to old key to do MTLS
new_cert_path="$(hostname).new.crt"  #path to new certificate after renewal
new_private_key_path="$(hostname).new.key"  #path to new private key
new_csr_path="$(hostname).new.csr"  #path to new CSR
#########################################################################

reenrollEndpoint=$url/.well-known/est/$profile/simplereenroll


curlcmd="curl -s -k"






print_green() {
  local message="$1"
  echo -e "\e[32m${message}\e[0m"
}

print_red() {
  local message="$1"
  echo -e "\e[31m${message}\e[0m"
}


openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout "${new_private_key_path}" -out "${new_csr_path}" -subj "/emailAddress=webmaster@example.com/CN=$(hostname)"


${curlcmd} -X POST  $reenrollEndpoint --data-binary "@${new_csr_path}"  --cert "${old_cert_path}" --key "${old_key_path}" -H "Content-Type: application/pkcs10" 

