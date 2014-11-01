#!/usr/bin/env bash
#
# Check number of opened files
#
# Usage: check_max_open_files.sh [-w warning] [-c critical]
#     -w, --warning WARNING         Warning value (percent)
#     -c, --critical CRITICAL       Critical value (percent)
#     -h, --help                    Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --warning|-w)
      warn=$2
      shift
      ;;
    --critical|-c)
      crit=$2
      shift
      ;;
    --help|-h)
      sed -n '2,9p' "$0" | tr -d '#'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exec "$0" --help
      exit 3
      ;;
  esac
  shift
done

if ! hash lsof &>/dev/null; then
  echo "CRITICAL - lsof command not found"
  exit 2
fi

warn=${warn:=75}
crit=${crit:=90}

opened_files=$(lsof | wc -l)
max_open_files=$(cat /proc/sys/fs/file-max)

if [[ -z $opened_files ]] || [[ -z $max_open_files ]]; then
  echo "ERROR - Can't find opened_files / max_open_files"
  exit 3
fi

percentage=$((opened_files * 100 / max_open_files))
status="${percentage}% (${opened_files} of ${max_open_files}) open files";

if [[ $percentage -gt $crit ]]; then
  echo "CRITICAL - ${status}"
  exit 2
elif [[ $percentage -gt $warn ]]; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi

echo "UNKNOWN - Error"
exit 3
