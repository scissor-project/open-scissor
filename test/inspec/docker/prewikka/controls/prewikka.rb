# encoding: utf-8

control "prewikka" do
  impact 1.0
  title "prewikka container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'fedora' }
  end

  describe sys_info do
    its('hostname') { should eq 'prewikka.scissor-project.com' }
  end

  packages = [
    'httpd',
    'iproute',
    'libpreludedb',
    'mariadb',
    'mod_wsgi',
    'net-tools',
    'nmap-ncat',
    'preludedb-mysql',
    'prewikka',
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

  init_script_path_content = '/opt/start-prewikka.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe file('/etc/httpd/conf.d/prewikka.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
  end

  describe file('/etc/prewikka/prewikka.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by_user('root') }
  end

  prelude_manager_process_name = 'httpd'
  describe processes(prelude_manager_process_name) do
    it { should exist }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe group('prelude') do
    it { should exist }
  end

  describe user('prewikka') do
    it { should exist }
    its('group') { should eq 'prelude' }
    its('home') { should eq '/home/prewikka' }
  end

  describe host('prelude-manager-db', port: '3306', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  ipv4_bind_all = '0.0.0.0'
  ipv4_localhost = '127.0.0.1'

  ipv6_bind_all = '::'
  ipv6_localhost = '::1'
  process_name = 'httpd'
  ports = [
    { :port_number => '80', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all, :process => prelude_manager_process_name }
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
