# for serverspec documentation: http://serverspec.org/
require_relative 'spec_helper'

pkgs = ['docker-gc', 'python-pip']

pkgs.each do |pkg|
  describe package("#{pkg}") do
    it { should be_installed }
  end
end

describe file('/etc/cron.hourly/docker-gc') do
  it { should_not be_file }
end

describe cron do
  it { should have_entry('*/15 * * * * /usr/sbin/docker-gc').with_user('root') }
end

describe file('/etc/docker-gc-exclude') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }

  its(:content) { should match /debian:jessie/ }
  its(:content) { should match /debian:wheezy/ }
  its(:content) { should match /ubuntu:latest/ }
end
