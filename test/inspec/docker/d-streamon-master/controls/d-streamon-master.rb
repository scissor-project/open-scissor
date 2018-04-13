# encoding: utf-8

control "d-streamon-master" do
  impact 1.0
  title "d-streamon-master container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'debian' }
  end

  packages = [
    'ansible',
    'build-essential',
    'cmake',
    'curl',
    'default-jre',
    'g++',
    'git',
    'libboost-dev',
    'libpcap-dev',
    'libpugixml-dev',
    'libssl-dev',
    'libzmq3-dev',
    'iproute2',
    'mongodb-server',
    'net-tools',
    'netcat',
    'redis-server',
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

  init_script_path_content = '/opt/start-d-streamon-master.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  nvm_dir_path = '/usr/local/nvm'

  describe os_env('NVM_DIR') do
    its('content') { should eq nvm_dir_path }
  end

  describe directory(nvm_dir_path) do
    it { should exist }
  end

  describe file(File.join(nvm_dir_path, 'nvm.sh')) do
    it { should exist }
    it { should be_file }
  end

  describe command('. "$NVM_DIR"/nvm.sh && command -v nvm') do
    its('stdout') { should match('nvm') }
  end

  d_streamon_path = '/opt/d-streamon'

  describe os_env('D_STREAMON_PATH') do
    its('content') { should eq d_streamon_path }
  end

  describe directory(d_streamon_path) do
    it { should exist }
  end

  streamon_path = File.join(d_streamon_path, 'streamon')

  describe os_env('STREAMON_PATH') do
    its('content') { should eq streamon_path }
  end

  describe directory(streamon_path) do
    it { should exist }
  end

  describe os_env('NVM_VERSION') do
    its('content') { should eq '0.33.8' }
  end

  describe file('/etc/ansible/ansible.cfg') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{host_key_checking = False}) }
  end

  node_process_name = 'node'
  describe processes(node_process_name) do
    it { should exist }
    its('entries.length') { should eq 3 }
  end

  mongodb_process_name = 'mongodb'
  describe upstart_service(mongodb_process_name) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe processes('gulp') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  ipv4_bind_all = '0.0.0.0'
  ipv4_localhost = '127.0.0.1'

  ipv6_bind_all = '::'
  ipv6_localhost = '::1'
  ports = [
    { :port_number => '3000', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all },
    { :port_number => '5570', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all, :process => node_process_name },
    { :port_number => '9999', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all, :process => node_process_name },
    { :port_number => '27017', :ipv4_address => ipv4_localhost, :ipv6_address => ipv6_localhost }
  ]

  ports.each do |port|
    port_number = "#{port[:port_number]}"

    describe port(port_number) do
      it { should be_listening }
      its('protocols') { should_not include 'udp' }
    end

    if port.has_key? :process
      process = "#{port[:process]}"
      describe port(port_number) do
        its('processes') { should include process }
      end
    end

    ipv4_address = "#{port[:ipv4_address]}"
    ipv6_address = "#{port[:ipv6_address]}"
    describe.one do
      describe port(port_number) do
        its('protocols') { should include 'tcp' }
        its('addresses') { should include ipv4_address }
      end
      describe port(port_number) do
        its('protocols') { should include 'tcp6' }
        its('addresses') { should include ipv6_address }
      end
    end
  end
end
