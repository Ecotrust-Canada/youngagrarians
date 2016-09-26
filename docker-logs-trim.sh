#!/bin/bash

# NOTES:
#  Requires jq (https://github.com/stedolan/jq)
#  Does NOT delete logfile (BAD IDEA) - simply trims file with redirect.
#  Handles single/all-running/all-existing containers - see end of script for usage.
#  Enjoy :-)


_get_container_logfile() {

  case $1 in

    running) _trim_container_logfile "$(docker ps -q)" $2
             ;;

        all) _trim_container_logfile "$(docker ps -aq)" $2
             ;;

          *) _trim_container_logfile "$(docker ps -a | awk -v ID=$1 '$1 ~ ID || $NF ~ ID {print $1}')" $2
             ;;

  esac

}


_trim_container_logfile() {

  TEMP=$(mktemp)

  case $2 in
    *[!0-9]*) echo "[lines] must be a number - \"$2\" is not a number."
              exit -1
              ;;
        ''|*) MAX=${2:-1000}
              ;;
  esac


  if [ -z $1 ]
  then
    echo "Container name/id unknown!"
    exit -1
  else
    for container in $1
    do
      logfile="$logfile $(docker inspect $container | jq -r '.[].LogPath')"
      echo "Keeping $MAX lines: $logfile"

      tail -n ${MAX} $logfile > $TEMP
      # Uncomment the next line when you trust the script!
      # cat $TEMP > $logfile
    done
  fi

  rm $TEMP
}


if [ -a "$(which jq)" ]
then
  case $1 in
    --trim) if [ -z $2 ]
            then
              echo "Container name/id missing!"
              exit -1
            else
              _get_container_logfile $2 $3
            fi
            ;;

    --trim-running) _get_container_logfile running $2
                    ;;

    --trim-all) _get_container_logfile all $2
                ;;

    *) echo "Usage:"
       echo "  --trim {container} [lines]   Keep [lines] of logfile for a single container"
       echo "  --trim-running     [lines]   Keep [lines] of logfile for all running containers"
       echo "  --trim-all         [lines]   Keep [lines] of logfile for all containers"
       echo "Default: lines=1000"
       exit -1
       ;;
  esac
else
  echo "Requires \"jq\""
  exit -1
fi
