# docker-cloudsqlproxy
Google CloudSQL proxy service

This repo creates a wrapper (entrypoint) script to be used in the Google distributed
CloudSQL proxy container.  The entrypoint.sh script autoruns when you run the
docker container created using the Dockerfile in this repo.  All the settings for
the CloudSQL proxy are "passed" in using environment variables - enabling a much
simplier configuration.

The script assumes one of two forms of service account authentication.
  1) A service account json file that is mounted into the docker container
     either under the default path (/etc/sqlproxy-service-account.json) or under
     the path specified by the environment var (CLOUDSQL_CREDENTIAL_FILE)
  2) Or using the "application" default service account.  This is either 
     the service account used to create the GCE compute instance the docker 
     is running on OR what ever the current user is authed as if they are 
     running it on a non-GCE host.

There are also two methods of setting the connection string used by the proxy.
  1) Specify an explicit list of one or more databases using the environment 
     variable (CLOUDSQL_CONNECTION_LIST).  This list must contain at least
     one connection setting using the following format.  Multiple settings
     should be comman seperated and all use UNIQUE port numbers (PORT)

     GOOGLE_PROJECT:CLOUDSQL_ZONE:CLOUDSQL_INSTANCE=0.0.0.0:PORT

     GOOGLE_PROJECT: Google project where cloudsql instance resides
     CLOUDSQL_ZONE: Zone that the cloudsql instance resides
     CLOUDSQL_INSTANCE: the exact name of the cloudsql instance
     PORT: the TCP port number that the cloudsql proxy will listen on for 
      connections to the cloudsql instance.

  2) By specifying all of the following as environment variables.  Using this 
     method supports only a single cloudsql instance.

     GOOGLE_PROJECT: Google project where cloudsql instance resides
     CLOUDSQL_ZONE: Zone that the cloudsql instance resides
     CLOUDSQL_INSTANCE: the exact name of the cloudsql instance
     PORT: the TCP port number that the cloudsql proxy will listen on for
      connections to the cloudsql instance.

Additional settings:

  CLOUDSQL_MAXCONNS: set the max number of database connections the cloudsql
    proxy will support.  Default is unlimited
  CLOUDSQL_LOGGING: Logging setting.  Default is verbose logging

  

