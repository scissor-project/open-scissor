# encoding: utf-8

control "flume" do
  impact 1.0
  title "flume container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  describe sys_info do
    its('hostname') { should eq 'flume.scissor-project.com' }
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

  describe host('kafka', port: '9092', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('zookeeper', port: '2181', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('semantics', port: '20000', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('semantics', port: '30000', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
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

  describe file(File.join(flume_config_path, 'ingest', 'ingest.conf')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{avro_host = semantics}) }
    its('content') { should match(%r{avro_port = 20000}) }
    its('content') { should match(%r{bind = 0.0.0.0}) }
  end

  describe file(File.join(flume_config_path, 'ingest', 'flume-env.sh')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{java.rmi.server.hostname=flume}) }
  end

  describe file(File.join(flume_config_path, 'filter', 'filter.conf')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{avro_host = semantics}) }
    its('content') { should match(%r{avro_port = 30000}) }
    its('content') { should match(%r{bind = 0.0.0.0}) }
  end

  describe file(File.join(flume_config_path, 'output', 'output.conf')) do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{bind = 0.0.0.0}) }
    its('content') { should match(%r{brokerList = kafka:9092}) }
  end

  describe file('/opt/zookeeper-agent/conf/agent.properties') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{agent.zookeeper.hostport = zookeeper:2181}) }
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

  describe os_env('ZOOKEEPER_AGENT_PATH') do
    its('content') { should eq "/opt/zookeeper-agent" }
  end

  init_script_path_content = '/opt/start-flume.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe processes('java') do
    it { should exist }
    its('entries.length') { should eq 4 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  ports = [
    '5445',
    '5446',
    '5447',
    '10000',
    '15222',
    '20000',
    '44444'
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
