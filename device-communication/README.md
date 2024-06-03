# Device Communication API

Device communication API enables users and applications to send configurations and commands to devices via HTTP(S)
endpoints as well as retrieve states of devices.

![img.png](img.png)

### Application

The application is reactive and uses the Quarkus framework for the application and Vert.x tools for the HTTP server.

### Hono internal communication

The application uses [Google's PubSub](https://cloud.google.com/pubsub/docs/overview?hl=de) service to communicate with
the command router.

## API endpoints

#### commands/{tenantId}/{deviceId}

- POST : post a command for a specific device

<p>

#### states/{tenantId}/{deviceId}?numStates=(int 0 - 10)

- GET : list of device states

#### configs/{tenantId}/{deviceId}?numVersion=(int 0 - 10)

- GET : list of device config versions

- POST: create a device config version

For more information please see resources/api/hono-endpoint.yaml file.

## Pub/Sub - Internal Messaging

The application communicates with hono components via the internal messaging interface (implemented for Google PubSub).
The settings for the internal messaging component can be found in the application.yaml file.

### Events

The application subscribes to all tenants' event topic at startup to listen for config requests.

#### MQTT config request (empty notification)

Expected message attributes:

- deviceId
- tenantId
- content-type (must be "application/vnd.eclipse-hono-empty-notification")
- ttd (must be -1)

#### HTTP config request

Expected message attributes:

- deviceId
- tenantId
- ttd (must not be blank or empty)
- orig_adapter (must be "hono-http")
- orig_address (must contain "config")

### States

The application subscribes to all tenants' state topic at startup.

Expected message attributes:

- deviceId
- tenantId

States are read only.

### Configs

The application publishes the latest device configuration when:

- An empty notification event is received (MQTT device subscribed to the command topic)
- A config request from an HTTP device is received
- A new device config is created

Message attributes:

- deviceId
- tenantId
- correlation-id (the config version)
- subject (always set to "config")
- ack-required (always set to true)

Body:

A JSON object with the device config object.

After publishing a device config, the application waits internally for an acknowledgement from the device on the
command_response topic to update the "device_ack_time" in the database.

### Config ACK

Expected message attributes:

- deviceId
- tenantId
- correlation-id (the config version)
- content-type (must be "application/vnd.eclipse-hono-delivery-success-notification+json")
- subject (must be "config")

### Commands

A command will be published from the application to the command topic.

Attributes:

- deviceId
- tenantId
- subject (if not specified set to "command")
- response-required (optional)
- ack-required (optional)
- correlation-id (optional)
- timeout (optional)

Body:

The command as string.

If ack-required is set to "true", the request will wait for the duration of the specified timeout (in milliseconds)
for an acknowledgement from the device on the command_response topic.

### Command ACK

Expected message attributes:

- deviceId
- tenantId
- correlation-id
- content-type (must be "application/vnd.eclipse-hono-delivery-success-notification+json")
- subject (must not be "config")

## Database

The application uses a PostgreSQL database. All the database configurations can be found in the application.yaml file.

### Tables

- device_configs <br>
  Is used for saving device config versions
- device_registrations <br>
  Is used for validating if a device exist
- device_status <br>
  Is used for saving device states

### Migrations

When the application starts the tables will be created by the DatabaseSchemaCreator service.

### Running PostgresSQL container locally

The docker run command for running the PostgreSQL database locally:

``````

docker run -p 5432:5432 --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres

``````

After the container is running, log in to the container and with psql create the database. Then we have to set the
application settings.

Default PostgreSQl values:

- userName = postgres
- password = mysecretpassword

## Build and push the application's Docker image

Mavens auto build and push functionality can be enabled in the application.yaml settings:

````
quarkus:
  container-image:
  builder: docker
  build: true
  push: true
  image: "eclipse/hono-device-communication"
````

By running maven package, install or deploy the docker image will automatically be built and if push is enabled it will
push the image to the registry specified in the image path.

## OpenApi Contract-first

For creating the endpoints, Vert.x takes the openApi definition file and maps every endpoint operation-ID with a
specific handler function.

## Handlers

Handlers are providing callBack functions for every endpoint. Functions are going to be called automatically from the
Vert.x server every time a request is received.

## Adding a new endpoint

Adding new endpoint steps:

1. Add endpoint in openApi (hono-device-communication-v1.yaml) and swagger (hono-endpoint.yaml) file and set an
   operationId in the openApi file
2. Depending on the endpoint, create a new HttpEndpointHandler or use an existing one (in case it's a new one, add it to
   the availableHandlerServices within the VertxHttpHandlerManagerService)
3. Implement the method and set the routes within the handler

## PubSub Events

The application publishes and subscribes to the following topics:

publish:
* TENANT_ID.command

subscribe:
* TENANT_ID.command_response
* TENANT_ID.event
* TENANT_ID.event.state
* registry-tenant.notification

## Automatically create and delete PubSub topics and subscriptions

The application creates tenant topics and subscriptions when:

* The application starts, if they do not exist already
* A new tenant is created

The application deletes tenant topics and subscriptions when:

* A tenant is deleted