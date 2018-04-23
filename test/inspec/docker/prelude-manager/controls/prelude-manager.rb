# encoding: utf-8

control "prelude-manager" do
  impact 1.0
  title "prelude-manager container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'fedora' }
  end

  packages = [
    'iproute',
    'libpreludedb',
    'mariadb',
    'net-tools',
    'nmap-ncat',
    'prelude-manager',
    'prelude-manager-db-plugin',
    'prelude-tools',
    'preludedb-mysql',
    'preludedb-tools',
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

  init_script_path_content = '/opt/start-prelude-manager.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe file('/etc/prelude/prelude-registrator.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
  end

  describe file('/etc/prelude-manager/prelude-manager.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
  end

  describe file('/usr/lib/tmpfiles.d/prelude-manager.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
  end

  prelude_manager_process_name = 'prelude-manager'
  describe processes(prelude_manager_process_name) do
    it { should exist }
    its('entries.length') { should eq 2 }
  end

  prelude_admin_process_name = 'prelude-admin'
  describe processes(prelude_admin_process_name) do
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
  process_name = 'java'
  ports = [
    { :port_number => '4690', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all, :process => prelude_manager_process_name },
    { :port_number => '5553', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all, :process => prelude_admin_process_name }
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
