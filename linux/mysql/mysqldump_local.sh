#!/usr/bin/env bash
 set -o xtrace 
# author: jeanluc.rakotovao@gmail.com | jean-luc.rakotovao@alterway.fr
# example: arg1="${1:-}"

#{{{ USAGE
if [[ -z "$@" ]]
  then
    echo "usage :
    $0 <-c|-d> <-p /some/dst/path/> [-r days_of_retention]                
    -c  create dump             
    -d  delete dump             
    -p  dump destination path   
    -r  days of retention       
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
  __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
  
  # files 
  lock_file="/tmp/${__base}.lock"  
  
  # params 
  opt=$@ 

  # date 
  timestamp=$(date +%Y-%m-%d_%H-%M-%S)

  # bin substitution 
  mysql=$(which mysql) || (echo "[WARNING] mysql is not installed")
  mysqldump=$(which mysqldump) || (echo "[WARNING] mysqldump is not installed")
  gzip=$(which gzip) || (echo "[WARNING] gzip is not installed")
  gunzip=$(which gunzip) || (echo "[WARNING] gunzip is not installed")
#}}} INIT

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

#{{{ METHODS
  MkDump(){
  # execute the dump for each table 
  for db in $($mysql --show-warnings="false" --execute="show databases" | egrep "[:alnum:-_]" | grep -v "Database"); do 
    mkdir -p "${dump_path}/${timestamp}/${db}" || echo "The following directory already exists: ${dump_path}"
    for table in $($mysql --execute="use ${db}; show tables" | egrep "[:alnum:-_]" | grep -v "Tables_in"); do
      ${mysqldump} ${db} ${table} | ${gzip} > "${dump_path}/${timestamp}/${db}/${table}"
    done  
  done 
  }
  RollBack(){ 
    # Roll-back on exit non 0 
    rm -rf "${dump_path}/${timestamp}"; \
    RmLock
  }
#}}} METHODS

#{{{ BODY
  # only one dump process
  MkLock 
  MkDump || RollBack
  RmLock
  exit 0
#}}} BODY
