# encoding: utf-8

control "prelude-manager-db" do
  impact 1.0
  title "prelude-manager-db container check"
  desc "This control checks if the container is compliant"

  ipv4_bind_all = '0.0.0.0'
  ipv6_bind_all = '::'
  ports = [
    { :port_number => '3306', :ipv4_address => ipv4_bind_all, :ipv6_address => ipv6_bind_all }
  ]

  ports.each do |port|
    port_number = "#{port[:port_number]}"

    describe port(port_number) do
      it { should be_listening }
      its('protocols') { should_not include 'udp' }
    end

    ipv4_address = "#{port[:ipv4_address]}"
    ipv6_address = "#{port[:ipv6_address]}"
    describe.one do
      describe port(port_number) do
        its('protocols') { should include 'tcp' }
      end
      describe port(port_number) do
        its('protocols') { should include 'tcp6' }
      end
    end
    describe.one do
      describe port(port_number) do
        its('addresses') { should include ipv4_address }
      end
      describe port(port_number) do
        its('addresses') { should include ipv6_address }
      end
    end
  end
end
