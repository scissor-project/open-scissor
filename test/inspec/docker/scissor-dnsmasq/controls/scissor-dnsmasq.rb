# encoding: utf-8

control "scissor-dnsmasq" do
  impact 1.0
  title "scissor-dnsmasq container check"
  desc "This control checks if the container is compliant"

  process_name = "dnsmasq"

  describe service(process_name) do
    it { should_not be_enabled }
    it { should_not be_running }
  end

  describe processes(process_name) do
    it { should exist }
  end

  describe file('/etc/dnsmasq.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/dnsmasq_static_hosts.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
    its('content') { should match(%r{gateway}) }
  end

  describe file('/etc/dhcp-hosts/static-ip-leases.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
    its('content') { should match(%r{gateway}) }
    its('content') { should match(%r{kafka}) }
    its('content') { should match(%r{flume}) }
    its('content') { should match(%r{semantics}) }
    its('content') { should match(%r{logstash}) }
    its('content') { should match(%r{logstash24}) }
    its('content') { should match(%r{datasource24}) }
    its('content') { should match(%r{d-streamon-master}) }
    its('content') { should match(%r{d-streamon-slave}) }
    its('content') { should match(%r{prelude-manager-oss}) }
    its('content') { should match(%r{event-correlator}) }
    its('content') { should match(%r{prewikka-oss}) }
    its('content') { should match(%r{kafka-idmef-converter}) }
    its('content') { should match(%r{kafka-prelude-connector}) }
  end
end
