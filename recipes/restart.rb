include_recipe 'nettyapp::deploy'

node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nettyapp' || ( node[:deploy][application][:layers] && ( node[:deploy][application][:layers] & node[:opsworks][:instance][:layers] ).count == 0 )
    Chef::Log.debug("Skipping nettyapp::restart for application #{application} as it is not set as a nettyapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end

  ruby_block "restart nettyapp application #{application}" do
    block do
      Chef::Log.info("restart nettyapp application #{application} via: #{node[:nettyapp][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:nettyapp][application][:restart_server_command]}`)
      $? == 0
    end
  end

end
