#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook Name:: windows_print
# Provider:: printer
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
require 'mixlib/shellout'

action :create do
  if port_exists?
    Chef::Log.info{"#{new_resource.port_name} already created - checking driver."}
    new_resource.updated_by_last_action(false)
  else
    windows_print_port "#{new_resource.port_name}" do
      ipv4_address "#{new_resource.ip_address}"
    end
    
    Chef::Log.info{"#{new_resource.port_name} created."}
    new_resource.updated_by_last_action(true)
  end
  
  if driver_exists?
    Chef::Log.info{"#{new_resource.driver_name} already created - installing printer."}
    new_resource.updated_by_last_action(false)
  else
    windows_print_driver "#{new_resource.driver_name}" do
      inf_path "#{new_resource.inf_path}"
    end
    
    Chef::Log.info{"#{new_resource.driver_name} created."}
    new_resource.updated_by_last_action(true)
  end
      
  if printer_exists?
    Chef::Log.info{"#{new_resource.name} already created - nothing to do."}
    new_resource.updated_by_last_action(false)
  else
    powershell "#{new_resource.name}" do
      code "Add-Printer -Name \"#{new_resource.name}\" -DriverName \"#{new_resource.driver_name}\" -PortName \"#{new_resource.port_name}\" -Comment \"#{new_resource.comment}\"" 
    end
  end
end

action :delete do
  if printer_exists?
    powershell "#{new_resource.name}" do
      code "Remove-Printer -Name \"#{new_resource.name}\""
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("#{new_resource.name} not found - unable to delete.")
    new_resource.updated_by_last_action(false)
  end
end

def port_exists?
  check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_TCPIPPrinterPort -EnableAllPrivileges | where {$_.name -like '#{new_resource.port_name}'} | fl name\"").run_command
  check.stdout.include? new_resource.port_name
  #windows_print_port.run_action(port_exists?)
end

def driver_exists?
  case new_resource.environment
  when "x64"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Windows x64'} | fl name\"").run_command
    Chef::Log.info("#{new_resource.driver_name} x64 driver found.")
  when "x86"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Windows NT x86'} | fl name\"").run_command
    Chef::Log.info("#{new_resource.driver_name} x86 driver found.")
  when "Itanium"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Itanium'} | fl name\"").run_command
    Chef::Log.info("#{new_resource.driver_name} xItanium driver found.")
  else
    Chef::Log.info("Please use \"x64\", \"x86\" or \"Itanium\" as the environment type")
  end
  check.stdout.include? new_resource.driver_name
  #windows_print_driver.run_action(driver_exists?)
end

def printer_exists?
  check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_Printer -EnableAllPrivileges | where {$_.name -like '#{new_resource.name}'} | fl name\"").run_command
  check.stdout.include? new_resource.name
end