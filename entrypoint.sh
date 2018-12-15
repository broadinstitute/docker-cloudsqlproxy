#!/bin/sh
set -e
set -u
set -o pipefail

# wrapper script for cloud_sql_proxy program

# By using this entrypoint script in the docker image it provides a much 
#  simplier method of running the proxy.  Instead of having to specify the 
#  exact sqlproxy command via the CMD or run - you are able to just set
#  environment variables for the various settings
#
# This script assumes you will be using a service account as authenticaiton
#  either by mounting the sevice account json into the docker container or 
#  setting the appropriate role on the default service account

MISSING=""
CREDENTIALS=""
CLOUDSQL_PROXY_CMD="/cloud_sql_proxy"
SQLPROXY_ENVFILE=${SQLPROXY_ENVFILE:-"/etc/sqlproxy.env"}

# for now expect env file to be shell export var

# If env file exists then load environment from file
if [ -r "${SQLPROXY_ENVFILE}" ]
then
   # load shell exports into env
   . "${SQLPROXY_ENVFILE}"
fi

# Init vars if not set in environment
GOOGLE_PROJECT=${GOOGLE_PROJECT:-""}
CLOUDSQL_ZONE=${CLOUDSQL_ZONE:-""}
CLOUDSQL_INSTANCE=${CLOUDSQL_INSTANCE:-""}
PORT=${PORT:-"3306"}

# default to unlimited conns
CLOUDSQL_MAXCONNS=${CLOUDSQL_MAXCONNS-0}

# default to specified path
CLOUDSQL_CREDENTIAL_FILE=${CLOUDSQL_CREDENTIAL_FILE-"/etc/sqlproxy-service-account.json"}

# default to verbose logging
CLOUDSQL_LOGGING=${CLOUDSQL_LOGGING-"-verbose"}

# flag to enable using the application default service credentials
#  default is to not use default service account credentials
CLOUDSQL_USE_DEFAULT_CREDENTIALS=${CLOUDSQL_USE_DEFAULT_CREDENTIALS-"0"}

# CloudSQL instances to connect to
CLOUDSQL_CONNECTION_LIST=${CLOUDSQL_CONNECTION_LIST:-""}

# Usage message
usage() {
   echo "Usage message here"
   exit 1
}

# output version if you can
version() {
    if [ -x ${CLOUDSQL_PROXY_CMD} ]
    then
       echo
       ${CLOUDSQL_PROXY_CMD} -version
       echo
    else
       echo
       echo "Unable to output version, can not execute proxy command (${CLOUDSQL_PROXY_CMD})"
       echo
    fi
}

# check if command line flag were passed
TEMP=$(getopt -o vh --long version,help -- "$@")
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -v|--version)
             version 
             exit 1
           ;;
        -h|--help)
             usage
             exit 1
           ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# if passing in connection string via CLOUDSQL_CONNECTION_LIST env var
#  ignore env vars that are passed in that would be used to build
#  connection string

# No connection list set so must construct one from env vars
if [ -z "${CLOUDSQL_CONNECTION_LIST}" ]
then

   # validate required vars are set.  check each one so can provide more
   # specific error message indicating what is missing

   if [ -z "${GOOGLE_PROJECT}" ]
   then
      MISSING="GOOGLE_PROJECT ${MISSING}"
   fi

   if [ -z "${CLOUDSQL_ZONE}" ]
   then
      MISSING="CLOUDSQL_ZONE ${MISSING}"
   fi

   if [ -z "${CLOUDSQL_INSTANCE}" ]
   then
      MISSING="CLOUDSQL_INSTANCE ${MISSING}"
   fi

   if [ ! -z "${MISSING}" ]
   then
      echo "The following REQUIRED environment variables were NOT set:"
      echo
      for miss in ${MISSING}
      do
         case $miss in 
           "GOOGLE_PROJECT") echo "  GOOGLE_PROJECT: Google project name that CloudSQL instance resides"
             ;;
           "CLOUDSQL_ZONE") echo "  CLOUDSQL_ZONE: Google zone that instance resides in (us-central1-a, us-east1-b,..."
             ;;
           "CLOUDSQL_INSTANCE") echo "  CLOUDSQL_INSTANCE: Specific name of the CLoudSQL instance"
             ;;
         esac 
      done
      usage
      echo ; echo "Exitting!"
      exit 1
   fi

   # construct connection list from env vars
   CLOUDSQL_CONNECTION_LIST="${GOOGLE_PROJECT}:${CLOUDSQL_ZONE}:${CLOUDSQL_INSTANCE}=tcp:0.0.0.0:${PORT}"

fi
   
# determine what credentials will be used if flag not set then use a service
#  account json file.
if [ "${CLOUDSQL_USE_DEFAULT_CREDENTIALS}" -eq "0" ]
then
   if [ -r ${CLOUDSQL_CREDENTIAL_FILE} ]
   then
      CREDENTIALS="-credential_file=${CLOUDSQL_CREDENTIAL_FILE}"
   else
      echo "Unable to read credential file: (${CLOUDSQL_CREDENTIAL_FILE})! - Exitting"
      echo 
      exit 1
   fi
fi

# launch proxy via exec to overlay existing shell
exec ${CLOUDSQL_PROXY_CMD}  -max_connections=${CLOUDSQL_MAXCONNS} -instances=${CLOUDSQL_CONNECTION_LIST} ${CREDENTIALS}  ${CLOUDSQL_LOGGING}
