# encoding: utf-8

require 'digest'

control "zookeeper" do
  impact 1.0
  title "zookeeper container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  describe sys_info do
    its('hostname') { should eq 'zookeeper.scissor-project.com' }
  end

  packages = [
    'default-jre',
    'git',
    'iproute2',
    'net-tools',
    'netcat',
    'zookeeperd'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  describe directory('/etc/zookeeper/conf') do
    it { should exist }
  end

  describe directory('/etc/zookeeper/conf/.git') do
    it { should exist }
  end

  describe file('/etc/zookeeper/conf/.git/HEAD') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{master}) }
  end

  describe file('/etc/zookeeper/conf/configuration.xsl') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/environment') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/log4j.properties') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/zoo.cfg') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/zoo10.cfg') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/zoo11.cfg') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/zookeeper/conf/zoo12.cfg') do
    it { should exist }
    it { should be_file }
  end

  describe directory('/opt/zookeeper-lib') do
    it { should exist }
  end

  describe directory('/opt/zookeeper-lib/.git') do
    it { should exist }
  end

  describe file('/opt/zookeeper-lib/.git/HEAD') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{master}) }
  end

  describe directory('/opt/zookeeper-master') do
    it { should exist }
  end

  describe directory('/opt/zookeeper-master/.git') do
    it { should exist }
  end

  describe file('/opt/zookeeper-master/.git/HEAD') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{master}) }
  end

  describe file('/opt/zookeeper-master/bin/start-zookeeper.sh') do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe upstart_service('zookeeper') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe processes('java') do
    it { should exist }
    its('entries.length') { should eq 2 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  port_number = 2181

  describe port(port_number) do
    it { should be_listening }
    its('protocols') { should_not include 'udp' }
  end

  describe.one do
    describe port(port_number) do
      its('protocols') { should include 'tcp' }
      its('addresses') { should include '0.0.0.0' }
    end
    describe port(port_number) do
      its('protocols') { should include 'tcp6' }
      its('addresses') { should include '::' }
    end
  end
end
