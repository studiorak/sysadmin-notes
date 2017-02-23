#!/usr/bin/env bash
# author: jeanluc.rakotovao@gmail.com 

#{{{ USAGE
if [[ -z "$@" ]]
  then
    echo "usage :
    $0 < -c /some/keepalived/file.conf > < -o output_file.csv > [-d|--debug]               
    "
    exit 0
fi
#}}} USAGE

#{{{ INIT
  # some best practices 
  set -o errexit
  set -o pipefail
  set -o nounset
  
  # Set magic variables for current file & dir
  __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
  __base="$(basename ${__file} .sh)"
  __root="$(cd "$(dirname "${__dir}")" && pwd)"  
	
# params 
opt=$@ 

# bin substitution
MYGREP="$(which egrep) --color"

#}}} INIT


#{{{ PARAMS
  while getopts ":c:o:d" opt; do
    case $opt in
      c)
        conf_file="$OPTARG"
        ;;
      d)
         set -o xtrace 
        ;;
      o)
         output_file="$OPTARG" 
        ;;
      \?)
        echo "Invalid option: $OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option $OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done
#}}} PARAMS

#{{{ METHODS
Parse_conf(){
  ${MYGREP} "([\!]{1,3}\ [\{]{3,3}|virtual_server|real_server)" ${conf_file}
}
#}}} METHODS

#{{{ BODY
#Parse_conf | sed ':a;N;$!ba;s/\nvirtual/\;virtual/g' | sed ':a;N;$!ba;s/\n[ \t]*real_server/\;real_serveur/g' > $output_file || echo "no output file supplyed ! => -o <output_file.csv>" 
Parse_conf |sed ':a;N;$!ba;s/\nvirtual/\;virtual/g' | sed ':a;N;$!ba;s/\n[ \t]*real_server/\;real_serveur/g' | sed 's/{//g' > $output_file  
#}}} BODY
