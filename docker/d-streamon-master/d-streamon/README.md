# D-StreaMon

A Distributed Framework for Network Monitoring

![screenshot](public/img/d-streamon_screenshot.png)

## Description

Distributed StreaMon (D-StreaMon) is an orchestration
framework for distributed monitoring on NFV network
architectures. It relies on the StreaMon platform, a solution
for network monitoring originally designed for traditional
middleboxes.

## Test

### Run test probe

To perform a simple D-streamon test use open-scissor.xml

The configuration file uses the default IP addresses and creates a probe capable of detecting the portscan on the slave machine.

### Probe alert

To see the probes' alerts, for example, you can use the command:
```
nmap 172.18.0.3
```

## Network informations

The Master machine and the Slave machine have one network interface (eth0).
The ZMQ PROXY run inside the Master machine.

Network data:

| Variable Name | Description                 | Value        |
| ------------- | --------------------------- | ------------ |
| PORT          | Web Port                    | `9999`       |
| PORT          | Swagger Port                | `3000`       |
| PORT          | ZMQ PROXY Port to subscribe | `5570`       |
| ZMQ PROXY IP  | IP Address                  | `172.18.0.2` |
| Master IP     | IP Address                  | `172.18.0.2` |
| Slave  IP     | IP Address                  | `172.18.0.3` |
