# Change Log

## [Unreleased](https://github.com/scissor-project/open-scissor/tree/HEAD)

**Implemented enhancements:**

- Comment Requirements section contents in PULL\_REQUEST\_TEMPLATE.md [\#36](https://github.com/scissor-project/open-scissor/issues/36)
- Configure Appveyor CI [\#32](https://github.com/scissor-project/open-scissor/issues/32)
- Configure Vagrantfile validation during CI builds [\#31](https://github.com/scissor-project/open-scissor/issues/31)
- Remove prelude-correlator-oss VM from Vagrantfile [\#28](https://github.com/scissor-project/open-scissor/issues/28)
- Rename cnit-correlator to event-correlator and add its description to README [\#25](https://github.com/scissor-project/open-scissor/issues/25)
- Configure camera IP and hostname via DHCP [\#24](https://github.com/scissor-project/open-scissor/issues/24)
- Set domain in Vagrantfile [\#23](https://github.com/scissor-project/open-scissor/issues/23)
- Use parameters in provisioning scripts [\#21](https://github.com/scissor-project/open-scissor/issues/21)
- Configure Travis CI to run shellcheck [\#19](https://github.com/scissor-project/open-scissor/issues/19)
- Improve network interface selection with sed [\#18](https://github.com/scissor-project/open-scissor/issues/18)
- Configure the default route through the gateway [\#17](https://github.com/scissor-project/open-scissor/issues/17)
- Configure a gateway VM [\#15](https://github.com/scissor-project/open-scissor/issues/15)
- Choose a license for OpenSCISSOR [\#14](https://github.com/scissor-project/open-scissor/issues/14)
- Configure a testing framework for the infrastructure [\#13](https://github.com/scissor-project/open-scissor/issues/13)
- Configure an "internal only" network interface for each VM [\#11](https://github.com/scissor-project/open-scissor/issues/11)
- Configure dnsmasq [\#10](https://github.com/scissor-project/open-scissor/issues/10)
- Remove unneeded commands from configuration scripts [\#5](https://github.com/scissor-project/open-scissor/issues/5)
- Avoid using SlipStream commands [\#4](https://github.com/scissor-project/open-scissor/issues/4)
- Add GitHub templates for contributions, pull requests and issues [\#30](https://github.com/scissor-project/open-scissor/pull/30) ([ferrarimarco](https://github.com/ferrarimarco))
- cnit-correlator VM [\#20](https://github.com/scissor-project/open-scissor/pull/20) ([agil3b3ast](https://github.com/agil3b3ast))

**Fixed bugs:**

- NoBrokersAvailable in kafka-idmef-converter [\#53](https://github.com/scissor-project/open-scissor/issues/53)
- Bad configuration syntax in kafka-idmef-converter [\#49](https://github.com/scissor-project/open-scissor/issues/49)
- Missing pyyaml in kafka-idmef-converter [\#48](https://github.com/scissor-project/open-scissor/issues/48)
- kafka-idmef-converter "unbound variable" in deployment [\#45](https://github.com/scissor-project/open-scissor/issues/45)
- Cannot ping gitlab.scissor-project.com from VM [\#43](https://github.com/scissor-project/open-scissor/issues/43)
- prelude-manager should be resilient to reboots [\#41](https://github.com/scissor-project/open-scissor/issues/41)
- prelude-manager-oss iptables configuration is not persisted [\#38](https://github.com/scissor-project/open-scissor/issues/38)
- Default route configuration does not work in Fedora. The connectivity is broken [\#35](https://github.com/scissor-project/open-scissor/issues/35)
- NetworkManager does not run the dispatcher.d scripts for DHCP network interfaces on the first up event [\#33](https://github.com/scissor-project/open-scissor/issues/33)
- Gateway networking service fails during "vagrant up" [\#29](https://github.com/scissor-project/open-scissor/issues/29)
- kafka VM configuration fails during post-install \(404 on kafka URL\) [\#26](https://github.com/scissor-project/open-scissor/issues/26)
- Kafka VM deployment.sh script uses an hardcoded network interface and IPs [\#16](https://github.com/scissor-project/open-scissor/issues/16)
- Prelude Correlator and Prelude Connector cannot connect to the Prelude Manager [\#6](https://github.com/scissor-project/open-scissor/issues/6)
- New iptables rules to open 2181 and  9092 in kafka VM [\#54](https://github.com/scissor-project/open-scissor/pull/54) ([agil3b3ast](https://github.com/agil3b3ast))
- Modified configuration syntax in kafka-idmef-converter [\#51](https://github.com/scissor-project/open-scissor/pull/51) ([agil3b3ast](https://github.com/agil3b3ast))
- Add pyyaml dependency in kafka-idmef-converter [\#50](https://github.com/scissor-project/open-scissor/pull/50) ([agil3b3ast](https://github.com/agil3b3ast))
- Dynamically validate deployment script parameters [\#46](https://github.com/scissor-project/open-scissor/pull/46) ([ferrarimarco](https://github.com/ferrarimarco))
- Add a prefix to the locally managed domain [\#44](https://github.com/scissor-project/open-scissor/pull/44) ([ferrarimarco](https://github.com/ferrarimarco))
- Make prelude-manager service resilient to reboots by configuring it as a service [\#42](https://github.com/scissor-project/open-scissor/pull/42) ([agil3b3ast](https://github.com/agil3b3ast))
- Saved prelude-manager-oss iptables rules after reload [\#40](https://github.com/scissor-project/open-scissor/pull/40) ([agil3b3ast](https://github.com/agil3b3ast))
- Disable Vagrant interface default route in fedora [\#39](https://github.com/scissor-project/open-scissor/pull/39) ([ferrarimarco](https://github.com/ferrarimarco))
- Changed prelude-manager-oss provisioning to bento/fedora-26 [\#37](https://github.com/scissor-project/open-scissor/pull/37) ([agil3b3ast](https://github.com/agil3b3ast))
- Restart NetworkManager after dispatcher scripts creation [\#34](https://github.com/scissor-project/open-scissor/pull/34) ([ferrarimarco](https://github.com/ferrarimarco))

**Merged pull requests:**

- Fix in flume deployment [\#27](https://github.com/scissor-project/open-scissor/pull/27) ([devbrand](https://github.com/devbrand))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*