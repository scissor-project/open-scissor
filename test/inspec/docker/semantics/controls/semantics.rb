# encoding: utf-8

control "semantics" do
  impact 1.0
  title "semantics container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  packages = [
    'default-jre',
    'flume-ng',
    'flume-ng-agent',
    'iproute2',
    'net-tools',
    'netcat',
    'wget'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  describe file('/etc/apt/sources.list.d/cloudera.list') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
  end

  describe apt('http://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh') do
    it { should exist }
    it { should be_enabled }
  end

  describe command('apt-key adv --list-public-keys --with-fingerprint --with-colons') do
    its('stdout') { should match(%r{Cloudera Apt Repository}) }
  end

  describe directory('/opt/morphline-lib') do
    it { should exist }
  end

  flume_config_path = '/opt/flume-config/conf'

  describe file(File.join(flume_config_path, 'enrich_semantics', 'enrich_semantics.conf')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{avro_host = flume}) }
    its('content') { should match(%r{avro_port = 10000}) }
    its('content') { should match(%r{bind = 0.0.0.0}) }
  end

  describe file(File.join(flume_config_path, 'enrich_semantics', 'flume-env.sh')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{java.rmi.server.hostname=semantics}) }
  end

  describe file(File.join(flume_config_path, 'xform_semantics', 'xform_semantics.conf')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{avro_host = flume}) }
    its('content') { should match(%r{avro_port = 20000}) }
    its('content') { should match(%r{bind = 0.0.0.0}) }
  end

  describe file(File.join(flume_config_path, 'xform_semantics', 'flume-env.sh')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{java.rmi.server.hostname=semantics}) }
  end

  describe os_env('FLUME_CONFIG_PATH') do
    its('content') { should eq "/opt/flume-config" }
  end

  describe os_env('MORPHLINE_LIB_PATH') do
    its('content') { should eq "/opt/morphline-lib" }
  end

  scissor_log_path = '/var/log/scissor'

  describe os_env('SCISSOR_LOG_DIR') do
    its('content') { should eq scissor_log_path }
  end

  describe directory(scissor_log_path) do
    it { should exist }
  end

  init_script_path = '/opt/start-semantics.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path }
  end

  describe file(init_script_path) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe processes('java') do
    it { should exist }
    its('entries.length') { should eq 2 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  ports = [
    '5467',
    '5067',
    '20000',
    '30000'
  ]

  ports.each do |port_number|
    describe port(port_number) do
      it { should be_listening }
      its('processes') { should include 'java' }
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
end
