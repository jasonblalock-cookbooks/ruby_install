require 'spec_helper'

describe 'ruby_install::default' do
  describe file('/usr/local/bin/ruby-install') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode 755 }
  end

  describe command('which ruby-install') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match %r{/usr/local/bin/ruby-install} }
  end

  describe command('ruby-install --version') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match /ruby-install: 0.6.0/ }
  end
end
