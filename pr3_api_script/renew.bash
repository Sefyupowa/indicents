
Endpoint_OneAccount="https://onelogin.stg.axa.com/as/token.oauth2"
Endpoint_Celia="https://api-pki-pp-v3.corp.intraxa/ago-celia-v1-vrs/"
Profile_Celia="PP1_API_SystemAuth"
certificateId=""
access_token=""


print_green() {
  local message="$1"
  echo -e "\e[32m${message}\e[0m"
}

print_red() {
  local message="$1"
  echo -e "\e[31m${message}\e[0m"
}

body=$(cat <<EOF
{
  "certificateId": "$certificateId",
  "module": "webra",
  "workflow": "renew",
  "requesterComment": null,
  "csrInput": {
    "text": null,
    "file": null
  },
  "template": {
    "keyType": "rsa-3072"
  },
  "type": "cent",
  "profile": "$Profile_Celia"
}
EOF
)



response=$(curl -s -k -X POST "${Endpoint_Celia}v1/requests/submit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d "$body") 

print_green "Certificate renewal response:"
print_green "Certificate ID:"
certificateId="$(echo $response | jq -r '.certificate._id')"
echo "$certificateId"
print_green "Profile used:"
echo $response | jq -r ".profile"

print_green "Certificate request response:"
echo $response | jq -r ".certificate.certificate"
