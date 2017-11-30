# OpenSCISSOR

* Development branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=development)](https://travis-ci.org/scissor-project/open-scissor) [![Build status](https://ci.appveyor.com/api/projects/status/9vmd89riib7akp79/branch/development?svg=true)](https://ci.appveyor.com/project/scissor-project/open-scissor/branch/development)
* Master branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=master)](https://travis-ci.org/scissor-project/open-scissor) [![Build status](https://ci.appveyor.com/api/projects/status/9vmd89riib7akp79/branch/master?svg=true)](https://ci.appveyor.com/project/scissor-project/open-scissor/branch/master)

This is an open implementation of the SCISSOR project.

The goal of this project is to have a fully functional virtualized environment
up and running with the minimal amount of manual steps.

# How to run

## Dependencies

- [Vagrant](https://www.vagrantup.com/) 2.0.0+
- [Virtualbox](https://www.virtualbox.org/) 5.1.30+

## Run

1. Install the dependencies
1. Clone this repository
1. Run `vagrant up` from the cloned repository directory

## Details
For each component we have two phases:
1. Provisioning: Vagrant spins up a VM to host the component
1. Configuration: Vagrant runs the desired configuration procedures to bring the
VM in the desired state

We tested this setup on a 8-core CPU and 16 GB of RAM.

# Components
Each component is deployed in it's own Virtual Machine.

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
1. `prelude-manager-oss`: IDMEF database to store IDMEF objects. Can be accessed through libprelude or via mysql direct access. A service (`prelude-registrator`) has been added to enable automatic registration.
1. `event-correlator`: Connects to the prelude database (prelude-manager) and applies correlation rules to incoming events to detect advanced attacks.
1. `prewikka-oss`: Web interface that connects to the `prelude-manager` (via direct mysql access) and displays alerts via http.
1. `kafka-idmef-converter`: Gets messages from kafka coming from the CCL, applies a filter, converts them to IDMEF, serializes them and sends them back to kafka on a dedicated topic (currently named IDMEF).
1. `kafka-prelude-connector`: Gets messages from kafka on the IDMEF topic, unserializes them and sends them to the `prelude-manager` instance (using libprelude).
1. `gateway`: VM that act as a gateway to the outside world. All traffic is routed through this VM. It also hosts DHCP and DNS servers.

# Known Issues

Currently a couple of Vagrant issues prevent this environment from starting with a single `vagrant up` command. As a workaround you can start each VM separately by running `vagrant up <machine-name>` for each machine. To get a list of all the machines in the environment run `vagrant status`.

# Issues and Contributions
If you have issue or want to contribute to the project, please create a new
GitHub issue or pull request.

Note that collaborators cannot push directly to `development` and `master` branches
but should open a pull request against these branches.
