#!/usr/bin/sh

select_random_tsa_with_error_log () {
    local servers=(
        "https://tsp.sic.tech/tsp/tsprequest"
        "http://timestamp.sectigo.com"
        "http://timestamp.globalsign.com/tsa/r6advanced1"
        "http://timestamp.digicert.com"
        "http://timestamp.apple.com/ts01"
        "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
        "http://ts.ssl.com"
        "https://freetsa.org/tsr"
    )

    local max_retries=3
    local error_log="error.tsa.servers.txt"

    # Shuffle the array to try different servers if the first one fails
    local shuffled_servers=($(shuf -e "${servers[@]}"))

    for server in "${shuffled_servers[@]}"; do
        local attempt=0
        
        while [ $attempt -lt $max_retries ]; do
            # Check if server is reachable (connect timeout 2s, total timeout 5s)
            # TSA servers usually return 405 or 200 on a blank POST/GET; 
            # we just check if the site is reachable (exit code 0)
            if curl -s --head --connect-timeout 2 "$server" > /dev/null; then
                echo "$server"
                return 0
            else
                ((attempt++))
                echo "Attempt $attempt failed for $server. Retrying..." >&2
                sleep 1
            fi
        done

        # If we reach here, all 3 retries for this specific server failed
        echo "$(date): $server is down after $max_retries attempts" >> "$error_log"
    done

    echo "Error: No reachable TSA servers found." >&2
    return 1
}


select_random_tsa () {
    # Returns a space-separated list of URLs
    local servers=(
        "https://tsp.sic.tech/tsp/tsprequest"
        "http://timestamp.sectigo.com"
        "http://timestamp.globalsign.com/tsa/r6advanced1"
        "http://timestamp.digicert.com"
        "https://tsp.sic.tech/tsp/tsprequest"
        "http://timestamp.apple.com/ts01"
        "http://timestamp.globalsign.com/tsa/r6advanced1"
        "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
        "http://ts.ssl.com"
        "https://freetsa.org/tsr"
    )

    local index=$(( RANDOM % ${#servers[@]} ))

    echo "${servers[$index]}"
}

CURL_FILE=request.html
TSR_FILE=$(printf "%s%s" $CURL_FILE ".tsr")

curl_tsa_create_tsr () {
   url=$1
   tsa_url=$(select_random_tsa)

   curl $url | tee $CURL_FILE | \
   openssl ts -query -sha512 | \
      curl -H "Content-Type: application/timestamp-query" --data-binary @- $tsa_url > $TSR_FILE;
}

curl_tsr_to_text () {
  tsr=$1
  openssl ts -reply -in $tsr -text
}

DEBUG_TSR=True

request () {
  url=$1
  
  curl_tsa_create_tsr $url;

  if [[ $DEBUG_TSR -eq True ]] ;then
    curl_tsr_to_text $TSR_FILE
  fi
}

