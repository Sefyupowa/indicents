#! /bin/bash
Endpoint_OneAccount="https://onelogin.stg.axa.com/as/token.oauth2"
Secret=""
ClientID="bfkwvy1l2i"
Endpoint_Celia="https://api-pki-pp-v3.corp.intraxa/ago-celia-v1-vrs/"
Profile_Celia="PP1_API_SystemAuth"


read -s -p "Enter Secret: " Secret
echo
iat=$(date +%s)
exp=$((iat + 3600))
jti=$(openssl rand -hex 16)

header='{"alg":"HS256","typ":"JWT"}'
#######
#Functions

print_red() {
  local message="$1"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "\e[31m[${ts}] ${message}\e[0m"
}

print_green() {
  local message="$1"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "\e[32m[${ts}] ${message}\e[0m"
}

base64url()
{
	base64 -w 0 | sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=*$//g'
}


generate_jwt_token(){
    local header=$1
    local payload=$2
    local secret=$3
    local encoded_header="$(printf "%s" "${header}" | base64url)"
    local encoded_payload="$(printf "%s" "${payload}" | base64url)"
    local signature="$(printf "%s" "${encoded_header}.${encoded_payload}" | openssl dgst -sha256 -hmac "$secret" -binary | base64url)"
    local JWT_TOKEN="${encoded_header}.${encoded_payload}.${signature}"
    echo $JWT_TOKEN
}



payload=$(cat <<EOF
{
  "iss": "$ClientID",
  "sub": "$ClientID",
  "aud": "$Endpoint_OneAccount",
  "iat": $iat,
  "exp": $exp,
  "jti": "$jti"
}
EOF
)


JWT=$(generate_jwt_token "$header" "$payload" "$Secret")
print_green "JWT:"
echo "$JWT"

#Request auth value from ESG

response=$(curl -s -k -X POST "$Endpoint_OneAccount" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --proxy "$Proxy" \
  -d "grant_type=client_credentials" \
  -d "client_id=$ClientID" \
  -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
  -d "client_assertion=$JWT" \
  -d "scope=urn:axa:axa-go:celia:generic-integration-framework"
)

#print_green "response:"
#echo $response
access_token=$(echo $response  | jq -r .access_token)
print_green "access_token:"
echo $access_token

if [ -z "$access_token" ]; then
  print_red "Failed to obtain access token."
  exit 1
fi

#Check identity from CELIA
response=$(curl -s -k -H "Authorization: Bearer $access_token" "${Endpoint_Celia}v1/security/principals/self")
celia_id=$(echo $response  | jq -r '.identity.identifier')
print_green "CELIA identifier:" 
echo "$celia_id" 

if [ -z "$celia_id" ]; then
  print_red "Failed to obtain CELIA identifier."
  exit 1
fi

#Request certificate

body=$(cat <<EOF
{
  "profile": "$Profile_Celia",
  "module": "webra",
  "workflow": "enroll",
  "template": {
    "subject": [
      {"element": "cn.1", "value": "test.corp.intraxa"},
      {"element": "o.1", "value": "AXA GROUP OPERATIONS FRANCE"},
      {"element": "ou.1"},
      {"element": "ou.2"},
      {"element": "ou.3"},
      {"element": "ou.4"},
      {"element": "e.1"},
      {"element": "l.1"},
      {"element": "st.1"},
      {"element": "c.1", "value": "FR"}
    ],
    "sans": [
      {"type": "DNSNAME", "value": ["test.corp.intraxa"]}
    ],
    "labels": [
      {"label": "Country", "value": "FR"},
      {"label": "Region", "value": "SE"},
      {"label": "Entity", "value": "AXA GROUP OPERATIONS FRANCE"},
      {"label": "Comment", "value": "MyCommentHere"},
      {"label": "Environment", "value": "PRE"}
    ],
    "keyType": "rsa-3072",
    "team": {"value": "silva_84756820dbe587802f555c88dc96191b"},
    "contactEmail": {"value": "badr.ouarafana@axa.com"}
  },
  "requesterComment": null
}
EOF
)

response=$(curl -s -k -X POST "${Endpoint_Celia}v1/requests/submit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d "$body")

echo $response >response.json


print_green "Certificate ID:"
certificateId="$(echo $response | jq -r '.certificate._id')"
echo "$certificateId"
print_green "Profile used:"
echo $response | jq -r ".profile"

print_green "Certificate request response:"
echo $response | jq -r ".certificate.certificate"