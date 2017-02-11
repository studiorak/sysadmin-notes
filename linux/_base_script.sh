#set -o xtrace 
#!/usr/bin/env bash
# author: jeanluc.rakotovao@gmail.com | jean-luc.rakotovao@alterway.fr
# example: arg1="${1:-}"

#{{{ USAGE
if [[ -z "$@" ]]
  then
    echo "usage"
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
  __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
  
  # files 
  lock_file="/tmp/${__base}.lock"  
  
  # optargs params 
  opt=$@ 

  # bin substitution 
  mysql=$(which mysql) || (echo "[WARNING] mysql is not installed")
  mysqldump=$(which mysqldump) || (echo "[WARNING] mysqldump is not installed")
  gzip=$(which gzip) || (echo "[WARNING] gzip is not installed")
  gunzip=$(which gunzip) || (echo "[WARNING] gunzip is not installed")
#}}} INIT

#{{{ LOCKFILE
  ErrLock(){
    echo "this process is already owned by $(cat $lock_file) with $lock_file"
    exit 1
  }
  RmLock(){
    rm -f $lock_file 
  }
  MkLock(){
    set -o noclobber; echo "$$" > "$lock_file" 2> /dev/null || ErrLock
    set +o noclobber
  }
#}}} LOCKFILE 

#{{{ PARAMS
  while getopts ":cdp:" opt; do
    case $opt in
      c)
        create=true
        ;;
      d)
        delete=true 
        ;;
      p)
        dump_path="$OPTARG"
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
  MkDump(){
    echo "function MkDump"
    echo "-c was triggered, Parameter: $1" >&2
  }
  RmDump(){
    echo "function RmDump"
    echo "-d was triggered, Parameter: $1" >&2
  }
#}}} METHODS

#{{{ BODY
  # only one dump process
  exit 0
#}}} BODY
