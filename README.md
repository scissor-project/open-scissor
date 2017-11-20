# OpenSCISSOR

* Development branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=development)](https://travis-ci.org/scissor-project/open-scissor)
* Master branch: [![Build Status](https://travis-ci.org/scissor-project/open-scissor.svg?branch=master)](https://travis-ci.org/scissor-project/open-scissor)

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
1. `kafka`
1. `flume`
1. `semantics`
1. `logstash`
1. `logstash24`
1. `datasource24`: data producer used in development/test scenarios.
1. `d-streamon-master`
1. `d-streamon-slave`
1. `prelude-manager-oss`: IDMEF database to store IDMEF objects. Can be accessed through libprelude or via mysql direct access. A service (`prelude-registrator`) has been added to enable automatic registration.
1. `prelude-correlator-oss`: Connects to the prelude database and applies correlation rules to incoming events to detect advanced attacks.
1. `prewikka-oss`: Web interface that connects to the `prelude-manager` (via direct mysql access) and displays alerts via http.
1. `kafka-idmef-converter`: Gets messages from kafka coming from the CCL, applies a filter, converts them to IDMEF, serializes them and sends them back to kafka on a dedicated topic (currently named IDMEF).
1. `kafka-prelude-connector`: Gets messages from kafka on the IDMEF topic, unserializes them and sends them to the `prelude-manager` instance (using libprelude).
1. `gateway`: VM that act as a gateway to the outside world. All traffic is routed through this VM.

# Issues and Contributions
If you have issue or want to contribute to the project, please create a new
GitHub issue or pull request.
