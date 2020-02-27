#
# Cookbook Name:: windows_print
# Recipe:: default
#
# Copyright 2013, Texas A&M
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

features = ['Printing-Server-Foundation-Features', 'Printing-Server-Role']
# Install additional role if Full Server Install (not ServerCore)
if registry_data_exists?(
  'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion',
  { name: 'InstallationType', type: :string, data: 'Server' },
  :machine
)
  features << 'Printing-AdminTools-Collection'
end
features << 'ServerManager-Core-RSAT'
features << 'ServerManager-Core-RSAT-Role-Tools'
features.each do |feature|
  windows_feature feature do
    action :install
  end
end
