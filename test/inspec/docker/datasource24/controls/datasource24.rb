# encoding: utf-8

control "datasource24" do
  impact 1.0
  title "datasource24 container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  packages = [
    'default-jre',
    'filebeat',
    'iproute2',
    'g++',
    'libapr1',
    'libapr1-dev',
    'libdbi1',
    'libperl5.22',
    'libzmq1',
    'libzmq-dev',
    'net-tools',
    'netcat',
    'nxlog-ce',
    'python-zmq',
    'wget'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  scissor_log_path = '/var/log/scissor'

  describe os_env('SCISSOR_LOG_DIR') do
    its('content') { should eq scissor_log_path }
  end

  describe directory(scissor_log_path) do
    it { should exist }
  end

  init_script_path_content = '/opt/start-datasource24.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe file('/usr/include/zmq.hpp') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
  end

  describe file('/usr/include/zmq_addon.hpp') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
    its('mode') { should cmp '0644' }
  end

  describe directory('/opt/zmq-bash-push') do
    it { should exist }
  end

  nx_log_ce_file_name = 'nxlog-ce_2.9.1716_ubuntu_1604_amd64.deb'
  describe os_env('NX_LOG_CE_FILE_NAME') do
    its('content') { should eq nx_log_ce_file_name }
  end

  describe file(File.join('/tmp', nx_log_ce_file_name)) do
    it { should_not exist }
  end

  filebeat_file_name = 'filebeat_1.3.1_amd64.deb'
  describe os_env('FILEBEAT_FILE_NAME') do
    its('content') { should eq filebeat_file_name }
  end

  describe file(File.join('/tmp', filebeat_file_name)) do
    it { should_not exist }
  end

  filebeat_config_directory_path = '/etc/filebeat'
  describe directory(filebeat_config_directory_path) do
    it { should exist }
  end

  describe file(File.join(filebeat_config_directory_path, 'filebeat.yml')) do
    it { should exist }
  end

  describe file(File.join(filebeat_config_directory_path, 'filebeat.template.json')) do
    it { should exist }
  end

  describe file(File.join(filebeat_config_directory_path, 'filebeat.template-es2x.json')) do
    it { should exist }
  end

  describe directory('/var/log/scissor/filebeat') do
    it { should exist }
  end

  describe upstart_service('nxlog') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe upstart_service('filebeat') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end
end
