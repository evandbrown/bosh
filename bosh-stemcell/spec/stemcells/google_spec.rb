require 'spec_helper'

describe 'Google Stemcell', stemcell_image: true do
  it_behaves_like 'udf module is disabled'

  context 'installed by system_parameters' do
    describe file('/var/vcap/bosh/etc/infrastructure') do
      it { should contain('google') }
    end
  end

  context 'installed by bosh_disable_password_authentication' do
    describe 'disallows password authentication' do
      subject { file('/etc/ssh/sshd_config') }

      it { should contain /^PasswordAuthentication no$/ }
    end
  end

  context 'installed by system_google_packages' do
    let(:mode) { '644' }
    let(:owner) { 'root' }
    let(:group) { 'root' }
    case ENV['OS_NAME']
      when 'ubuntu'
        [
          '/var/lib/dpkg/info/google-compute-engine-init-wheezy.postinst',
          '/var/lib/dpkg/info/google-compute-engine-init-wheezy.conffiles',
          '/var/lib/dpkg/info/google-compute-engine-wheezy.md5sums',
          '/var/lib/dpkg/info/google-compute-engine-init-wheezy.md5sums',
          '/var/lib/dpkg/info/google-compute-engine-wheezy.list',
          '/var/lib/dpkg/info/google-compute-engine-init-wheezy.prerm',
          '/var/lib/dpkg/info/google-compute-engine-init-wheezy.list',
          '/etc/init.d/google-accounts-daemon',
          '/etc/init.d/google-instance-setup',
          '/etc/init.d/google-clock-skew-daemon',
          '/etc/init.d/google-ip-forwarding-daemon',
          '/usr/bin/google_instance_setup',
          '/usr/bin/google_ip_forwarding_daemon',
          '/usr/bin/google_accounts_daemon',
          '/usr/bin/google_clock_skew_daemon',
          '/usr/bin/google_metadata_script_runner',
        ].each do |conf_file|
          describe file(conf_file) do
            it { should be_file }
            it { should be_owned_by(owner) }
            it { should be_grouped_into(group) }
          end
        end
      when 'centos', 'rhel'
        [
          '/usr/lib/systemd/system/google-accounts-manager.service',
          '/usr/lib/systemd/system/google-accounts-manager.service',
          '/usr/lib/systemd/system/google-clock-sync-manager.service'
        ].each do |conf_file|
          describe file(conf_file) do
            it { should be_file }
            it { should be_mode(mode) }
            it { should be_owned_by(owner) }
            it { should be_grouped_into(group) }
          end
        end
    end
  end
end
