#
# Cookbook Name:: backup_script
# Attributes:: default
#
# Copyright 2010, edelight GmbH
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

if node[:mongodb][:backup_script][:is_backup]
	cookbook_file "#{node[:mongodb][:backup_script][:backup_path]}/replicaset_backup.sh" do
	  source "replicaset_backup.sh"
	  mode 0755
	end

	cron "Mongodb Nightly Backup" do
		minute "0"
		hour "2"
    command "#{node[:mongodb][:backup_script][:backup_path]}/replicaset_backup.sh"
    action :create
	end
end
