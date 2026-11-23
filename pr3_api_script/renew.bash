
Endpoint_OneAccount="https://onelogin.stg.axa.com/as/token.oauth2"
Endpoint_Celia="https://api-pki-pp-v3.corp.intraxa/ago-celia-v1-vrs/"
Profile_Celia="PP1_API_SystemAuth"
certificateId="6b047c110d439c3cd3e7881f"
access_token="eyJhbGciOiJSUzI1NiIsImtpZCI6Im0yWC1QZlM1Z2RDVGlBendCeU1udG5nQzVsb19SUzI1NiIsInBpLmF0bSI6InZreGQifQ.eyJzY29wZSI6InVybjpheGE6YXhhLWdvOmNlbGlhOmdlbmVyaWMtaW50ZWdyYXRpb24tZnJhbWV3b3JrIiwiY2xpZW50X2lkIjoiYmZrd3Z5MWwyaSIsImlzcyI6Imh0dHBzOi8vb25lbG9naW4uc3RnLmF4YS5jb20iLCJqdGkiOiJ1bjBkcnZUNkVOZ1Jvd0Z6T3d3dE1rWVJYYTVVdEROaCIsImV4cCI6MTc5NTQ1OTYwOSwiaWF0IjoxNzk1NDU2MDA5fQ.WeH6APluJTDeHWf3gmKd_mrx46kzUPyHdCv6zD8Xwq5lMIOddRMa10Or6Cql4ieGpltmbqqcRZ2jz_xz3H_5hB-dUB51qaTIbCKwX3SvEOpnGZEW0sM0-4nfzdmjbZFuAZltFBYg9yb9X2W8Lg7_IfB4bJch6jNWs2O3Xd-v-NXe3DJy9yhqsVa85JO5thHGaDKdqVxuQ4O-Huo-HDlPrBYh0iVm_HfGzYDUwdY5ELY32qeBNmyNg2Pm1HGpX2I1SpPB258C1q_NLnRE6jbJ_Ob6qz4otJG5evjlfsupfYyM4G7pJUiXr3VmPJuhfwH2O9OV8EQIXvmhPgQAkxXc5Q"


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
