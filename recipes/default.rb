#
# Cookbook Name:: ruby_install
# Recipe:: default
#
# Copyright (c) 2016 Jason Blalock, All Rights Reserved.

include_recipe 'apt::default'

packages = %w{ libssl1.0.0 libssl1.0.0-dbg }

packages.each do |pkg|
  package pkg do
    action :upgrade
  end
end

file_name = "ruby-install-#{node['ruby_install']['checksum']}"
dir_path = "#{Chef::Config['file_cache_path']}/ruby_install"
file_path = "#{dir_path}/#{file_name}.tar.gz"

directory "#{dir_path}/#{file_name}" do
  recursive true
  action :create
end

remote_file file_path do
  source node['ruby_install']['url']
  checksum node['ruby_install']['checksum']
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'Install ruby-install' do
  cwd "#{dir_path}/#{file_name}"
  command %{sudo make uninstall && sudo make clean && sudo make install}
  action :nothing
end

bash 'extract_tarball' do
  cwd dir_path
  code <<-EOH
    mkdir -p #{dir_path}/#{file_name}
    tar xzvf #{file_name}.tar.gz -C #{dir_path}/#{file_name} --strip-components=1
    EOH
  only_if { Dir["#{dir_path}/#{file_name}/*"].empty? }
  notifies :run, resources(execute: 'Install ruby-install'), :immediately
end

# Make sure ruby-install has correct ownership, without creating a fake
# ruby-install file
file '/usr/local/bin/ruby-install' do
  owner 'root'
  group 'root'
  only_if { ::File.exist?("/usr/local/bin/ruby-install") }
end
