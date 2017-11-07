# OpenSCISSOR
This is an open implementation of the SCISSOR project.

The goal of this project is to have a fully functional virtualized environment
up and running with the minimal amount of manual steps.

# How to run

## Dependencies

- [Vagrant](https://www.vagrantup.com/) 2.0.0
- [Virtualbox](https://www.virtualbox.org/) 5.1.30+

## Run

1. Clone this repository
1. Run `vagrant up`

# Components
Each component is deployed in it's own Virtual Machine.

Here is a list of all the managed components (as you can see from the
Vagrantfile) with a brief description:
1. `kafka`
1. `flume`
1. `semantics`
1. `logstash`
1. `logstash24`
1. `datasource24`: data producer used in development/test scenarios
1. `d-streamon-master`
1. `d-streamon-slave`
1. `prelude-manager-oss`
1. `prelude-correlator-oss`
1. `prewikka-oss`
1. `kafka-idmef-converter`
1. `kafka-prelude-connector`

# Issues and Contributions
If you have issue or want to contribute to the project, please create a new
GitHub issue or pull request.
