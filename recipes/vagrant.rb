# encoding: utf-8
#
# Cookbook Name:: octohost
# Recipe:: vagrant
#
# Copyright (C) 2014, Darron Froese <darron@froese.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'curl'

execute 'install keys for vagrant user' do # ~FC041 ~ETSY004
  command "curl -L #{node['vagrant']['keys']} >> /home/vagrant/.ssh/authorized_keys"
end

execute 'install keys to push to git user' do # ~FC041
  command "curl -L #{node['git']['keys']} >> /home/git/.ssh/authorized_keys"
  not_if { File.exist?('/home/git/.ssh/authorized_keys') }
end

bash 'update domain name in /etc/default/octohost' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    sed -i '8s/.*/PUBLIC_IP=\"192\.168\.62\.86\"/' /etc/default/octohost
    sed -i '9s/.*/PRIVATE_IP=\"192\.168\.62\.86\"/' /etc/default/octohost
    sed -i '11s/.*/DOMAIN_SUFFIX=\"octodev\.io\"/' /etc/default/octohost
  EOH
end

cookbook_file '/etc/nginx/additional-vhosts/consul.conf' do
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, 'service[proxy]', :delayed
end
