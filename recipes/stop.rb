node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nettyapp' || ( node[:deploy][application][:layers] && ( node[:deploy][application][:layers] & node[:opsworks][:instance][:layers] ).count == 0 )
    Chef::Log.debug("Skipping nettyapp::stop for application #{application} as it is not set as a nettyapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end

  ruby_block "stop nettyapp application #{application}" do
    block do
      Chef::Log.info("stop nettyapp via: #{node[:nettyapp][application][:stop_server_command]}")
      Chef::Log.info(`#{node[:nettyapp][application][:stop_server_command]}`)
      $? == 0
    end
  end

end
