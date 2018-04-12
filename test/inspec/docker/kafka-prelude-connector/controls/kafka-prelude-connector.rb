# encoding: utf-8

control "kafka-prelude-connector" do
  impact 1.0
  title "kafka-prelude-connector container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'redhat' }
  end

  describe sys_info do
    its('hostname') { should eq 'kafka-prelude-connector.scissor-project.com' }
  end

  packages = [
    'epel-release',
    'iproute',
    'kafka-prelude-connector',
    'net-tools',
    'nmap-ncat',
    'prelude-tools',
    'python2-pip'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  pip_packages = [
    'kafka',
    'pip'
  ]

  pip_packages.each do |item|
    describe pip(item) do
      it { should be_installed }
    end
  end

  p12file_contents = '/root/assystem-prelude.p12'
  describe os_env('P12FILE') do
    its('content') { should eq p12file_contents }
  end

  p12file_raw_contents = '/root/assystem-prelude.raw'
  describe os_env('P12FILE_RAW') do
    its('content') { should eq p12file_raw_contents }
  end

  describe os_env('PRIVATE_KEY') do
    its('content') { should eq '/root/assystem-prelude.priv.pem' }
  end

  describe os_env('PUBLIC_KEY') do
    its('content') { should eq '/root/assystem-prelude.pub.pem' }
  end

  describe os_env('PASSWORD') do
    its('content') { should eq '48c9AyFfU8' }
  end

  describe os_env('PRELUDE_PROFILE') do
    its('content') { should eq 'connector' }
  end

  prelude_gpg_key_contents = '/root/RPM-GPG-KEY-Prelude-IDS'
  describe os_env('PRELUDE_GPG_KEY') do
    its('content') { should eq prelude_gpg_key_contents }
  end

  scissor_log_path = '/var/log/scissor'

  describe os_env('SCISSOR_LOG_DIR') do
    its('content') { should eq scissor_log_path }
  end

  describe directory(scissor_log_path) do
    it { should exist }
  end

  init_script_path_content = '/opt/start-kafka-prelude-connector.sh'
  describe os_env('INIT_SCRIPT_PATH') do
    its('content') { should eq init_script_path_content }
  end

  describe file(init_script_path_content) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe file(p12file_contents) do
    it { should exist }
    it { should be_file }
  end

  describe file(p12file_raw_contents) do
    it { should exist }
    it { should be_file }
  end

  describe file(prelude_gpg_key_contents) do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/yum.repos.d/epel.repo') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/yum.repos.d/release.prelude-siem.com_assystem_pkgs_centos_7_.repo') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/yum.repos.d/scissor.repo') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/connector.conf') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/prelude/default/client.conf') do
    it { should exist }
    it { should be_file }
  end

  describe processes('connector') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe host('kafka', port: '9092', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('prelude-manager', port: '5553', protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe user('connector') do
    it { should exist }
    its('groups') { should eq ['connector', 'prelude']}
    its('home') { should eq '/home/connector' }
    its('shell') { should eq '/sbin/nologin' }
  end
end
