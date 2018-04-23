# encoding: utf-8

control "kafka" do
  impact 1.0
  title "kafka container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  packages = [
    'default-jre',
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

  describe directory('/opt/kafka') do
    it { should exist }
  end

  describe file('/opt/kafka/$KAFKA_FILENAME') do
    it { should_not exist }
  end

  describe file('/opt/kafka/config/log4j.properties') do
    it { should exist }
    it { should be_file }
  end

  describe file('/opt/kafka/bin/start-kafka.sh') do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe os_env('ADVERTISED_HOST') do
    its('content') { should eq "kafka" }
  end

  describe os_env('ADVERTISED_PORT') do
    its('content') { should eq "9092" }
  end

  describe os_env('LOG_RETENTION_HOURS') do
    its('content') { should eq "4" }
  end

  kafka_topics = [
    'cam',
    'env',
    'net',
    'scada'
  ]

  describe os_env('TOPICS') do
    its('content') { should eq kafka_topics.join(',') }
  end

  zookeeper_host = "zookeeper"
  zookeeper_port = "2181"
  zookeeper_host_port = zookeeper_host + ':' + zookeeper_port

  describe os_env('ZOOKEEPER_HOST') do
    its('content') { should eq zookeeper_host_port }
  end

  describe file('/opt/kafka/config/server.properties') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{advertised.host.name=kafka}) }
    its('content') { should match(%r{advertised.port=9092}) }
    its('content') { should match(%r{log.retention.hours=4}) }
    its('content') { should match(%r{zookeeper.connect=#{zookeeper_host_port}}) }
  end

  describe processes('java') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe file('/opt/kafka/kafka.pid') do
    it { should exist }
    it { should be_file }
  end

  port_number = 9092

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

  # wait for topic creation
  sleep(10)

  kafka_topics.each do |item|
    describe command("/opt/kafka/bin/kafka-topics.sh --list --zookeeper #{zookeeper_host_port} | grep #{item}") do
     its('stdout') { should match(%r{#{item}}) }
     its('exit_status') { should eq 0 }
    end
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end
end
