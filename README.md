# docker-cloudsqlproxy
Google CloudSQL proxy service

### Running with a single CloudSql DB
When running with a single database, set the following environment vars:

`GOOGLE_PROJECT`
`CLOUDSQL_ZONE`
`CLOUDSQL_INSTANCE`

### Running with multiple CloudSql DBs
When running with multiple databases, you must drop down to the lower level args from the proxy directly.  In this case, just use:

`CLOUDSQL_INSTANCES`