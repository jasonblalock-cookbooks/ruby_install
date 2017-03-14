#
# Cookbook Name:: ruby_install
# Attributes:: default
#
# Copyright (C) 2016 Jason Blalock, All Rights Reserved

default['ruby_install']['version'] = '0.6.1'
default['ruby_install']['checksum'] = 'b3adf199f8cd8f8d4a6176ab605db9ddd8521df8dbb2212f58f7b8273ed85e73'
default['ruby_install']['url'] = "https://codeload.github.com/postmodern/ruby-install/tar.gz/v#{node['ruby_install']['version']}"
default['ruby_install']['rubies'] = []
