# for serverspec documentation: http://serverspec.org/
require_relative 'spec_helper'

pkgs = ['docker-engine']
pips = ['docker-py', 'docker-compose']

pkgs.each do |pkg|
  describe package("#{pkg}") do
    it { should be_installed }
  end
end

pips.each do |pip|
  describe package("#{pip}") do
    it { should be_installed.by('pip') }
  end
end

describe service('docker') do
  it { should be_running }
  it { should be_enabled }
end

describe group('docker') do
  it { should exist }
  it { should have_gid 5002 }
end

describe user('docker') do
  it { should exist }
  it { should belong_to_group 'docker' }
  it { should have_uid 5002 }
end

describe file('/etc/default/docker') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }
end

describe file('/etc/docker/daemon.json') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }
end

describe file('/etc/logrotate.d/docker') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }
end

describe command('docker info | grep "Storage Driver:" | awk \'{ print $3 }\'') do
  its(:stdout) { should match /overlay2/}
end

describe command('docker info | grep "Docker Root Dir:" | awk \'{ print $4 }\'') do
  its(:stdout) { should match /\/data\/docker/}
end

describe command('cat /etc/docker/daemon.json | grep "max-size" | awk \'{ print $2 }\'') do
  its(:stdout) { should match /100m/}
end