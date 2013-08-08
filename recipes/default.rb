#
# Cookbook Name:: simpy
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

simpy_user = "simpy"
simpy_home = File.join("/", "home", simpy_user)

user simpy_user do
  supports manage_home: true
  shell "/bin/bash"
  home simpy_home
end


include_recipe "pypy::deb"
include_recipe "pypy::pip"

pypy_pip "virtualenv"

simpy_virtualenv = File.join(simpy_home, "simpy-env")

pypy_virtualenv simpy_virtualenv do
  interpreter "pypy"
  owner simpy_user
  group simpy_user
end

package "mercurial"

pypy_pip "hg+https://bitbucket.org/simpy/simpy" do
  virtualenv simpy_virtualenv
  user simpy_user
end

gem_package "bundler"

package "git"

simpy_ssh_directory = File.join(simpy_home, ".ssh")

directory simpy_ssh_directory do
  owner simpy_user
end

simpy_deploy_key = File.join(simpy_ssh_directory, "deploy_key")
vagrant_deploy_key_location = File.join("/", "vagrant", "deploy_key")
metal_deploy_key_location = File.join("/", "tmp", "deploy_key")

file simpy_deploy_key do
  is_vagrant = File.exists?("/vagrant") && File.directory?("/vagrant")
  mode 00600
  owner simpy_user
  content File.read is_vagrant ? vagrant_deploy_key_location : metal_deploy_key_location
end

simpy_ssh_wrapper = File.join(simpy_home, "deploy_ssh")

file simpy_ssh_wrapper do
  content <<-eos
#!/bin/sh
exec /usr/bin/ssh -o StrictHostKeyChecking=no -i #{ simpy_deploy_key } "$@"
eos
  mode 00755
  owner simpy_user
end

simpy_project_directory = File.join(simpy_home, "ggsn-models")

git simpy_project_directory do
  user simpy_user
  repository "git@github.com:fmetzger/ggsn-models.git"
  ssh_wrapper simpy_ssh_wrapper
end

simpy_simulation_directory = File.join(simpy_project_directory, "simulation")

bash "bundle install for simulation" do
  user simpy_user
  cwd simpy_simulation_directory
  code "bundle install --path vendor"
end
