# Purpose: Send-Tweet — General-purpose PowerShell utilities.
workflow Send-Tweet {
    param (
    [Parameter(Mandatory=$true)][string]$Message
    )

    InlineScript {      
        [Reflection.Assembly]::LoadWithPartialName("System.Security")  
        [Reflection.Assembly]::LoadWithPartialName("System.Net")  
        
        $status = [System.Uri]::EscapeDataString($Using:Message);  
        $oauth_consumer_key = "<YourAPIKey>";  
        $oauth_consumer_secret = "<YourAPISecret>";  
        $oauth_token = "<YourAccessToken>";  
        $oauth_token_secret = "<YourAccessTokenSecret>";  
        $oauth_nonce = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()));  
        $ts = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime();  
        $oauth_timestamp = [System.Convert]::ToInt64($ts.TotalSeconds).ToString();  
  
        $signature = "POST&";  
        $signature += [System.Uri]::EscapeDataString("https://api.twitter.com/1.1/statuses/update.json") + "&";  
        $signature += [System.Uri]::EscapeDataString("oauth_consumer_key=" + $oauth_consumer_key + "&");  
        $signature += [System.Uri]::EscapeDataString("oauth_nonce=" + $oauth_nonce + "&");   
        $signature += [System.Uri]::EscapeDataString("oauth_signature_method=HMAC-SHA1&");  
        $signature += [System.Uri]::EscapeDataString("oauth_timestamp=" + $oauth_timestamp + "&");  
        $signature += [System.Uri]::EscapeDataString("oauth_token=" + $oauth_token + "&");  
        $signature += [System.Uri]::EscapeDataString("oauth_version=1.0&");  
        $signature += [System.Uri]::EscapeDataString("status=" + $status);  
  
        $signature_key = [System.Uri]::EscapeDataString($oauth_consumer_secret) + "&" + [System.Uri]::EscapeDataString($oauth_token_secret);  
  
        $hmacsha1 = new-object System.Security.Cryptography.HMACSHA1;  
        $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($signature_key);  
        $oauth_signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($signature)));  
  
        $oauth_authorization = 'OAuth ';  
        $oauth_authorization += 'oauth_consumer_key="' + [System.Uri]::EscapeDataString($oauth_consumer_key) + '",';  
        $oauth_authorization += 'oauth_nonce="' + [System.Uri]::EscapeDataString($oauth_nonce) + '",';  
        $oauth_authorization += 'oauth_signature="' + [System.Uri]::EscapeDataString($oauth_signature) + '",';  
        $oauth_authorization += 'oauth_signature_method="HMAC-SHA1",'  
        $oauth_authorization += 'oauth_timestamp="' + [System.Uri]::EscapeDataString($oauth_timestamp) + '",'  
        $oauth_authorization += 'oauth_token="' + [System.Uri]::EscapeDataString($oauth_token) + '",';  
        $oauth_authorization += 'oauth_version="1.0"';  
    
        $post_body = [System.Text.Encoding]::ASCII.GetBytes("status=" + $status);   
        [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create("https://api.twitter.com/1.1/statuses/update.json");  
        $request.Method = "POST";  
        $request.Headers.Add("Authorization", $oauth_authorization);  
        $request.ContentType = "application/x-www-form-urlencoded";  
        $body = $request.GetRequestStream();  
        $body.write($post_body, 0, $post_body.length);  
        $body.flush();  
        $body.close();  
        $response = $request.GetResponse();
    }
 }