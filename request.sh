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

curl_tsa_create_tsr () {
   url=$1
   response_file=$2
   tsr_path=$3

   tsa_url=$(select_random_tsa)

   curl $url | tee $response_file | \
   openssl ts -query -sha512 | \
      curl -H "Content-Type: application/timestamp-query" --data-binary @- $tsa_url > $tsr_path;
}


TSR_TXT_DEFAULT_PATH=response.html.tsr.txt
curl_tsr_to_text () {
  tsr_file_path=$1
  tsr_txt_file_path=${2:-$TSR_TXT_DEFAULT_PATH}

  openssl ts -reply -in $tsr_file_path -text | tee $tsr_txt_file_path;
}

RESPONSE_DEFAULT_PATH=response.html
TSR_DEFAULT_PATH=response.html.tsr

DEBUG_TSR=True
request () {
  url=$1
  response_file_path=${2:-$RESPONSE_DEFAULT_PATH}
  tsr_file_path=${3:-$TSR_DEFAULT_PATH}
  tsr_txt_file_path=${4:-$TSR_TXT_DEFAULT_PATH}
  
  curl_tsa_create_tsr $url $response_file_path $tsr_file_path;

  if [[ $DEBUG_TSR -eq True ]] ;then
    curl_tsr_to_text $tsr_file_path $tsr_txt_file_path
  fi
}

##### 
# Usage Section
#####
usage () {
  echo """
Usage:

  The request function will generate both tsr and tsr.txt files that are the time proof of existence
  of the request itself;

    request <URL> <OUTPUT_TSR_FILE_PATH> <OUTPUT_TSR_TXT_FILE_PATH>
  """
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # echo "I am being EXECUTED. Running main logic..."
    if [[ -z "$1" ]]; then
        usage;
        exit 1
    fi
    
    request $@ 
else
   usage;
fi



