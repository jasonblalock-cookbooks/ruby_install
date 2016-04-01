require 'spec_helper'

describe 'ruby_install::install' do
  describe 'compiles and installs specified rubies into /opt/rubies' do
    context 'full ruby version specified' do
      describe command('/opt/rubies/ruby-2.2.4/bin/ruby -v') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /ruby 2.2.4.*/ }
      end

      describe command('/opt/rubies/ruby-2.3.0/bin/ruby -v') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /ruby 2.3.0.*/ }
      end

      describe command('/opt/rubies/jruby-1.7.24/bin/ruby -v') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /jruby 1.7.24.*/ }
      end
    end

    context 'partial ruby version specified' do
      describe command('ls /opt/rubies') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /ruby-2\.1\.\d{1,2}/ }
      end
    end
  end
end
