# OpenSCISSOR

* Development branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=development)](https://travis-ci.org/scissor-project/open-scissor) [![Build status](https://ci.appveyor.com/api/projects/status/9vmd89riib7akp79/branch/development?svg=true)](https://ci.appveyor.com/project/scissor-project/open-scissor/branch/development) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/dfe7a776e70040c38984a06b5ad3b225?branch=development)](https://www.codacy.com/app/ferrarimarco/open-scissor?utm_source=github.com&utm_medium=referral&utm_content=scissor-project/open-scissor&utm_campaign=badger&bid=5998790)
* Master branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=master)](https://travis-ci.org/scissor-project/open-scissor) [![Build status](https://ci.appveyor.com/api/projects/status/9vmd89riib7akp79/branch/master?svg=true)](https://ci.appveyor.com/project/scissor-project/open-scissor/branch/master) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/dfe7a776e70040c38984a06b5ad3b225?branch=master)](https://www.codacy.com/app/ferrarimarco/open-scissor?utm_source=github.com&utm_medium=referral&utm_content=scissor-project/open-scissor&utm_campaign=badger&bid=5998788)

This is an open implementation of the SCISSOR project.

The goal of this project is to have a fully functional virtualized environment up and running with the minimal amount of manual steps.

# How to run

## Dependencies

- [Docker](https://www.docker.com/) 17.12+
- [Docker Compose](https://docs.docker.com/compose/) 1.18.0

See https://github.com/ferrarimarco/open-development-environment-devbox for a ready-to-start development box.

## Run

1. Install the dependencies
1. Clone this repository
1. Run `docker-compose up` from the cloned repository directory

# Components
Each component is deployed in it's own Docker container.

Here is a list of all the managed components (as you can see from the
Vagrantfile) with a brief description:
1. `kafka`: provides an Apache Kafka message broker (the SMI component of SCISSOR) as well as Apache Zookeeper (needed by the Edge Agent Controller (see flume VM) and the Control and Coordination Agent (in this kafka VM)).
1. `flume`: provides parse, filter and output components of the Command and Control Layer (CCL) processing chain.
1. `semantics`: provides enrich and transform components of the CCL processing chain.
1. `logstash`: provides endpoints for the data handover between Monitoring Layer (ML) entities and the CCL (e.g. via filebeat and ZeroMQ)
1. `logstash24`: provides endpoints for the data handover between Monitoring Layer (ML) entities and the CCL (e.g. via filebeat and ZeroMQ)
1. `datasource24`: This machine is used exclusively for testing, generating artificial loads and replaying previously recorded data.
1. `d-streamon-master`
1. `d-streamon-slave`
1. `prelude-manager`: IDMEF database to store IDMEF objects. Can be accessed through libprelude or via mysql direct access. A service (`prelude-registrator`) has been added to enable automatic registration.
1. `prelude-manager-db`: MariaDB instance supporting `prelude-manager` and `prewikka`
1. `event-correlator`: Connects to the prelude database (prelude-manager) and applies correlation rules to incoming events to detect advanced attacks.
1. `prewikka`: Web interface that connects to the `prelude-manager` (via direct mysql access) and displays alerts via http.
1. `kafka-idmef-converter`: Gets messages from kafka coming from the CCL, applies a filter, converts them to IDMEF, serializes them and sends them back to kafka on a dedicated topic (currently named IDMEF).
1. `kafka-prelude-connector`: Gets messages from kafka on the IDMEF topic, unserializes them and sends them to the `prelude-manager` instance (using libprelude).

# Issues and Contributions
If you have issue or want to contribute to the project, please create a new GitHub issue or pull request.

Note that collaborators cannot push directly to `development` and `master` branches but should open a pull request against these branches.

# Running the Test Suite

## Dependencies

- Runtime dependencies listed above
- [InSpec](https://www.inspec.io) 1.50.1+

## Run
Run `test/test-docker-images.sh --docker-context-path=.` from the root of the project. This script will:

1. Lint Dockerfiles and shell scripts
1. Build each image
1. Start all the containers
1. Test all the containers for compliance

# Legacy Version

You can find what we consider the unmatained legacy version (Virtual Machines managed by Vagrant) by checking out the `1.0.0` git tag.
