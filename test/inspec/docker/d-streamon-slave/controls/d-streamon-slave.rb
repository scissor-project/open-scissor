# encoding: utf-8

control "d-streamon-slave" do
  impact 1.0
  title "d-streamon-slave container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  describe sys_info do
    its('hostname') { should eq 'd-streamon-slave.scissor-project.com' }
  end

  packages = [
    'libboost-dev',
    'libpcap-dev',
    'libzmq3-dev'
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

  init_script_path_content = '/opt/start-d-streamon-slave.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  node_process_name = 'sleep'
  describe processes(node_process_name) do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

end
