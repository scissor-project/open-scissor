# encoding: utf-8

control "logstash" do
  impact 1.0
  title "logstash container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  packages = [
    'default-jre',
    'iproute2',
    'libzmq3-dev',
    'logstash',
    'net-tools',
    'netcat',
    'wget'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  describe file('/etc/apt/sources.list') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
    its('content') { should match(%r{deb http://packages.elasticsearch.org/logstash/1.5/debian stable main}) }
  end

  describe apt('http://packages.elasticsearch.org/logstash/1.5/debian') do
    it { should exist }
    it { should be_enabled }
  end

  describe command('apt-key adv --list-public-keys --with-fingerprint --with-colons') do
    its('stdout') { should match(%r{Elasticsearch}) }
  end

  describe file('/etc/logstash/conf.d/syslogng.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0664' }
  end

  describe file('/etc/logrotate.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0664' }
  end

  describe file('/etc/cron.hourly/logrotate') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0755' }
  end

  describe upstart_service('logstash') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  init_script_path_content = '/opt/start-logstash.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  ports = [
    '8892',
    '8893'
  ]

  ports.each do |port_number|
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
end
