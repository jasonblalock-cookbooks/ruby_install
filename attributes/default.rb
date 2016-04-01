#
# Cookbook Name:: ruby_install
# Attributes:: default
#
# Copyright (C) 2016 Jason Blalock, All Rights Reserved

default['ruby_install']['version'] = '0.6.0'
default['ruby_install']['checksum'] = '3cc90846ca972d88b601789af2ad9ed0a496447a13cb986a3d74a4de062af37d'
default['ruby_install']['url'] = "https://codeload.github.com/postmodern/ruby-install/tar.gz/v#{node['ruby_install']['version']}"
default['ruby_install']['rubies'] = []
