#
# Cookbook Name:: simpy
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

simpy_user = node["simpy"]["user"]
simpy_home = File.join("/", "home", simpy_user)
simpy_virtualenv = File.join(simpy_home, node["simpy"]["virtualenv"])

user simpy_user do
  supports manage_home: true
  shell "/bin/bash"
  home simpy_home
end

include_recipe "pypy::deb"
include_recipe "pypy::pip"

pypy_pip "virtualenv"

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
