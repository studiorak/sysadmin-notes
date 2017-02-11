#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
# author: jeanluc.rakotovao@gmail.com | jean-luc.rakotovao@alterway.fr
# example: arg1="${1:-}"

#}}} usage 

usage="  \
Usage : \
"
[ ! -z "$@" ] || echo -e $usage

#}}} usage 
#{{{ best practices 

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace # uncomment when debugging

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

# script vars init 
lockfile="/tmp/${__base}.lock"  
opt=$@ 

#}}} best practices 
#{{{ lockfile 

lockfile_error(){
  echo "this process is already owned by $(cat $lockfile) with $lockfile"
  exit 1   
}
lockfile_rm(){
  rm -f $lockfile 
}
lockfile_put(){
  set -o noclobber; echo "$$" > "$lockfile" 2> /dev/null || lockfile_error
  set +o noclober
}

#}}} lockfile 
#{{{ functions

# here my functions 

#}}} functions
#{{{ handle params 

while getopts ":a:" opt; do
  case $opt in
    a)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
#}}} handle params 

lockfile_rm
exit 0
