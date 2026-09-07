# OS2Orgviewer

This is a web application that displays a chart over an organization and its members.
You can navigate the chart, display info on individual sections and people, and search for people or units within the organisation.
It pulls organization information from OS2MO REST API.

## Installation

Assuming you have [Node.js](https://nodejs.org/en/) and [npm](https://www.npmjs.com/) installed, check out this code and install the build dependencies:

```
git clone git@git.magenta.dk:rammearkitektur/os2orgviewer.git
cd os2orgviewer/app
npm install
```

### Development quick start

OS2orgviewer assumes you have a running OS2MO instance somewhere with access to it's API.
If that is not the case, you should start a local OS2MO instance like so:
1. Clone OS2MO and
```
cd os2mo
```
2. Make a file `docker-compose.override.yml` and edit it to insert this configuration:
```
services:
  mo:
    environment:
      OS2MO_AUTH: "false"
```
3. Start OS2MO
```
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
```
It will load the Kolding dummy dataset.
4. Start OS2orgviewer.
```
cd os2orgviewer
docker-compose up -d --build
```
You can now access OS2Orgviewer on http://localhost:8083/.

Refer to [the development section](./app/docs/development.md) for further development instructions.


### Deploy quick start

Inside the [os2orgviewer/app](./app) directory, run the build script

```
npm run build
```

The build is written to the repository's [dist](./dist) folder. Hook it up to a server, and you'll be good to go.

The build bakes the configuration into `index.html`, but a deployed container can override it at
startup - see [the configuration section](./app/docs/configuration.md).

## Documentation

[Document for the application can be found here.](./app/docs/index.md)

### Configuration documentation

Configuration details can be found in [the configuration section](./app/docs/configuration.md)
