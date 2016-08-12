include_recipe 'nettyapp::deploy'

node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nettyapp' || ( node[:deploy][application][:layers] && ( node[:deploy][application][:layers] & node[:opsworks][:instance][:layers] ).count == 0 )
    Chef::Log.debug("Skipping nettyapp::undeploy for application #{application} as it is not set as a nettyapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end

  ruby_block "stop nettyapp application #{application}" do
    block do
      Chef::Log.info("stop nettyapp application via: #{node[:nettyapp][application][:stop_server_command]}")
      Chef::Log.info(`#{node[:nettyapp][application][:stop_server_command]}`)
      $? == 0
    end
  end

  file "#{node[:monit][:conf_dir]}/nettyapp_#{application}_server.monitrc" do
    action :delete
    only_if do
      ::File.exists?("#{node[:monit][:conf_dir]}/nettyapp_#{application}_server.monitrc")
    end
  end

  directory "#{node[:deploy][application][:deploy_to]}" do
    recursive true
    action :delete

    only_if do
      ::File.exists?("#{node[:deploy][application][:deploy_to]}")
    end
  end
end
