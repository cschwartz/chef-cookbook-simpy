#
# Cookbook Name:: simpy
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

user "simpy" do
  supports manage_home: true
  shell "/bin/bash"
  home "/home/simpy"
end


include_recipe "pypy::deb"
include_recipe "pypy::pip"

pypy_pip "virtualenv"

pypy_virtualenv "/home/simpy/simpy-env" do
  interpreter "pypy"
  owner "simpy"
  group "simpy"
end

package "mercurial"

pypy_pip "hg+https://bitbucket.org/simpy/simpy" do
  virtualenv "/home/simpy/simpy-env"
  user "simpy"
end

gem_package "bundler"

package "git"

directory "/home/simpy/.ssh" do
  owner "simpy"
end

file "/home/simpy/.ssh/deploy_key" do
  mode 00600
  owner "simpy"
  if Dir["/vagrant"]
    content File.read("/vagrant/deploy_key")
  else
    content File.read("/tmp/deploy_key")
  end
end

file "/home/simpy/deploy_ssh" do
  content <<-eos
#!/bin/sh
exec /usr/bin/ssh -o StrictHostKeyChecking=no -i /home/simpy/.ssh/deploy_key "$@"
eos
  mode 00755
  owner "simpy"
end

git "/home/simpy/ggsn-models" do
  user "simpy"
  repository "git@github.com:fmetzger/ggsn-models.git"
  ssh_wrapper "/home/simpy/deploy_ssh"
end

bash "bundle install for simulation" do
  user "simpy"
  cwd "/home/simpy/ggsn-models/simulation"
  code "bundle install --path vendor"
end
