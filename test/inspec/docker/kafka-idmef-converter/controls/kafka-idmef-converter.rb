# encoding: utf-8

control "kafka-idmef-converter" do
  impact 1.0
  title "kafka-idmef-converter container check"
  desc "This control checks if the container is compliant"

  describe os[:family] do
    it { should eq 'redhat' }
  end

  packages = [
    'epel-release',
    'iproute',
    'kafka-idmef-converter',
    'net-tools',
    'ncat',
    'python2-pip',
    'wget'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  pip_packages = [
    'kafka',
    'pip',
    'pyyaml'
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

  describe os_env('NETCAT_FILE_NAME') do
    its('content') { should eq 'ncat-7.70-1.x86_64.rpm' }
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

  init_script_path_content = '/opt/start-kafka-idmef-converter.sh'
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

  describe file('/etc/converter.conf') do
    it { should exist }
    it { should be_file }
  end

  describe processes('converter') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end

  describe processes('tail') do
    it { should exist }
    its('entries.length') { should eq 1 }
  end
end
