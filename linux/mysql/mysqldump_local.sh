set -o xtrace 
#!/usr/bin/env bash
# author: jeanluc.rakotovao@gmail.com | jean-luc.rakotovao@alterway.fr
# example: arg1="${1:-}"

#}}} usage 
  usage="Usage : \n -c create \n -d delete \n -p dump path" 
  [ ! -z "$@" ] || (echo -e $usage; exit 0)
#}}} usage 

#{{{ best practices 
  set -o errexit
  set -o pipefail
  set -o nounset
  
  # Set magic variables for current file & dir
  __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
  __base="$(basename ${__file} .sh)"
  __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
  
  # script vars init 
  lockfile="/tmp/${__base}.lock"  
  opt=$@ 
  mysql=$(which mysql) || (echo "[WARNING] mysql is not installed")
  mysqldump=$(which mysqldump) || (echo "[WARNING] mysqldump is not installed")
  gzip=$(which gzip) || (echo "[WARNING] gzip is not installed")
  gunzip=$(which gunzip) || (echo "[WARNING] gunzip is not installed")
#}}} best practices 

#{{{ lockfile 
  ErrLock(){
    echo "this process is already owned by $(cat $lockfile) with $lockfile"
    exit 1
  }
  RmLock(){
    rm -f $lockfile 
  }
  MkLock(){
    set -o noclobber; echo "$$" > "$lockfile" 2> /dev/null || lockfile_error
    set +o noclobber
  }
#}}} lockfile 

#{{{ methods
  MkDump(){
    echo "function MkDump"
    echo "-c was triggered, Parameter: $1" >&2
  }
  RmDump(){
    echo "function RmDump"
    echo "-d was triggered, Parameter: $1" >&2
  }
#}}} methods

#{{{ handle params 
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
#}}} handle params 

RmLock
exit 0
