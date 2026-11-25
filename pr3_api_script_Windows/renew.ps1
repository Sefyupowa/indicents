################################################
# FUNCTIONS
################################################

## See https://gist.github.com/gitfvb/5a549572b2e3f596f41c996cbdde60fb



Function Get-HMACSHA512 {
    
    param(
         [Parameter(Mandatory=$true)][String]$data
        ,[Parameter(Mandatory=$true)][String]$key
    )
    
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256  
    $hmacsha.key = [Text.Encoding]::UTF8.GetBytes($key)
    $bytesToSign = [Text.Encoding]::UTF8.GetBytes($data)
    $sign = $hmacsha.ComputeHash($bytesToSign)

    return $sign

}

Function Get-StringFromByte {
    
    param(
        [Parameter(Mandatory=$true)][byte[]]$byteArray
    )

    $stringBuilder = ""
    $byteArray | ForEach { $stringBuilder += $_.ToString("x2") }
    return $stringBuilder

}

Function Get-Base64UrlEncodeFromString {
    
    param(
         [Parameter(Mandatory=$true)][String]$inputString
    )

    $inputBytes = [Text.Encoding]::UTF8.GetBytes($inputString)
    
    # Special "url-safe" base64 encode.
    $base64 = [System.Convert]::ToBase64String($inputBytes,[Base64FormattingOptions]::None).Replace('+', '-').Replace('/', '_').Replace("=", "")

    return $base64

}

Function Get-Base64UrlEncodeFromByteArray {
    
    param(
         [Parameter(Mandatory=$true)][byte[]]$byteArray
    )
   
    # Special "url-safe" base64 encode.
    $base64 = [System.Convert]::ToBase64String($byteArray,[Base64FormattingOptions]::None).Replace('+', '-').Replace('/', '_').Replace("=", "")

    return $base64

}

Function Get-Base64FromString {
    
    param(
         [Parameter(Mandatory=$true)][String]$inputString
    )

    $inputBytes = [Text.Encoding]::UTF8.GetBytes($inputString)
    
    # Special "url-safe" base64 encode.
    $base64 = [System.Convert]::ToBase64String($inputBytes,[Base64FormattingOptions]::None)

    return $base64

}

Function Get-Base64FromByteArray {
    
    param(
         [Parameter(Mandatory=$true)][byte[]]$byteArray
    )
    
    $base64 = [System.Convert]::ToBase64String($byteArray,[Base64FormattingOptions]::None)

    return $base64

}

# Add missing "=" at the end and check url-safe encodings
Function Check-Base64 {

    param(
         [Parameter(Mandatory=$true)][String]$inputString
    )

    #$input
    $encoded = $inputString.Replace('-','+').Replace('_','/')
    $d = $encoded.Length % 4
    if ( $d -ne 0 ) {
        $encoded  = $encoded.TrimEnd('=')
        if ( $d % 2 -gt 0 ) {
            $encoded += '='
        } else {
            $encoded += '=='
        }
    }
    return $encoded

}

Function Create-JWT {

    param(
          [Parameter(Mandatory=$true)][System.Collections.Specialized.OrderedDictionary]$headers
         ,[Parameter(Mandatory=$true)][System.Collections.Specialized.OrderedDictionary]$payload
         ,[Parameter(Mandatory=$true)][string]$secret
    )

    $headersJson = $headers | ConvertTo-Json -Compress
    $payloadJson = $payload | ConvertTo-Json -Compress
    $headersEncoded = Get-Base64UrlEncodeFromString -inputString $headersJson #[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($headersJson),[Base64FormattingOptions]::None)
    $payloadEncoded = Get-Base64UrlEncodeFromString -inputString $payloadJson #[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($payloadJson),[Base64FormattingOptions]::None)

    $content = "$( $headersEncoded ).$( $payloadEncoded )"

    $signatureByte = Get-HMACSHA512 -data $content -key $secret
    $signature = Get-Base64UrlEncodeFromByteArray -byteArray $signatureByte

    $jwt = "$( $headersEncoded ).$( $payloadEncoded ).$( $signature )"

    return $jwt

}

################################################
# Parameters
################################################



# OneAccount

$credential = Get-Credential -Message "Enter your oauth2 credentials"


#$credential.UserName, $credential.GetNetworkCredential()
$Endpoint_OneAccount = "https://onelogin.stg.axa.com/as/token.oauth2"
$Secret = $credential.GetNetworkCredential().Password
$ClientID = $credential.UserName

# CELIA
$Endpoint_Celia = "https://api-pki-pp-v3.corp.intraxa/ago-celia-v1-vrs/"
$Profile_Celia = "PP1_API_SystemAuth"

$headers = [ordered]@{
    "alg"="HS256"    
    "typ"="JWT"
}

$iat = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$exp = [DateTimeOffset]::Now.ToUnixTimeSeconds() + 3600
$jti = (New-Guid).Guid

$payload = [ordered]@{
  "iss"=$ClientID
  "sub"=$ClientID
  "aud"=$Endpoint_OneAccount
  "iat"=$iat
  "exp"=$exp  
  "jti"=$jti
}


#####################################################################################################################################
### Request OneAccount token
#####################################################################################################################################


Add-Type -AssemblyName System.Security
$JWT = Create-JWT -headers $headers -payload $payload -secret $secret

$response = Invoke-WebRequest -Uri $Endpoint_OneAccount -Method Post -Body @{
    grant_type = "client_credentials"
    client_id = $ClientID
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion= $JWT
    scope = 'urn:axa:axa-go:celia:generic-integration-framework'
} -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} 



$token = (ConvertFrom-Json $response.Content).access_token
Write-Host ("Token is: " + $token)

$whoami = (Invoke-WebRequest -uri ($Endpoint_Celia+"v1/security/principals/self") -Headers @{Authorization="Bearer $token"} -ErrorAction SilentlyContinue).Content
Write-Host ("`nSelf-identity is: " + ($whoami | ConvertFrom-Json).Identity.Identifier)


#####################################################################################################################################
### Parse CSR - PKCS#10
#####################################################################################################################################

$CertificateId = Read-Host -Prompt "Enter certificate ID"

$body3 = @"
{
  "certificateId": "$CertificateId",
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
"@





$req3 = Invoke-WebRequest -UseBasicParsing -Uri ($Endpoint_Celia+"v1/requests/submit") `
-Method "POST" `
-Headers @{
  "accept"="application/json"
  "Authorization"="Bearer $token"
} `
-ContentType "application/json" `
-Body $body3

Write-Host "DEBUG - Output"
$req3.Content | ConvertFrom-Json | ConvertTo-Json


$cert3 = ($req3.Content | ConvertFrom-Json).certificate.certificate
$id3 = ($req3.Content | ConvertFrom-Json).certificate._id

Write-Host "Generated Certificate is the following:"
Write-Host $cert3