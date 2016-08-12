
node[:deploy].each do |application, _|
  is_nettyapp = node[:deploy][application][:application_type] == 'nettyapp'
  instance_is_proper_layer = node[:deploy][application][:layers] && node[:deploy][application][:layers].any? {|app_layer| node[:opsworks][:instance][:layers].include?(app_layer)}
  if  !is_nettyapp || !instance_is_proper_layer
          Chef::Log.debug("Skipping nettyapp::deploy for application #{application} as it is not set as a nettyapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end

  nettyapp_deploy_dir do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    path    node[:deploy][application][:deploy_to]
  end

  nettyapp_scm do
    deploy_data   node[:deploy][application]
    app           application
  end

  revision = (node[:deploy][application][:scm][:revision] rescue nil)
  config = (node[:nettyapp][application][:config] or {})
  nettyapp_deploy_config_and_monit do
    application_name                application
    revision                        revision
    hostname                        node[:hostname]
    basicauth_users                 node[:nettyapp][application][:basicauth_users]
    nettyapp_application_settings   node[:nettyapp][application]
    deploy_to                       node[:deploy][application][:deploy_to]
    env_vars                        node[:nettyapp][application][:env]
    config_vars                     config
    config_file                     node[:nettyapp][application][:config_file]
    monit_conf_dir                  node[:monit][:conf_dir]
    group                           node[:deploy][application][:group]
    user                            node[:deploy][application][:user]
    test_url                        node[:deploy][application][:test_url]
  end

  ruby_block "restart nettyapp application #{application}" do
    block do
      Chef::Log.info("restart nettyapp app server via: #{node[:nettyapp][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:nettyapp][application][:restart_server_command]}`)
      $? == 0
    end
  end
end
