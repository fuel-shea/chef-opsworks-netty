include_attribute "nettyapp::configure"

node[:deploy].each do |application, _|

  if node[:deploy][application][:environment] && node[:deploy][application][:environment]["HOME"] && node[:deploy][application][:env]
    default[:nettyapp][application][:env] = {"HOME" => node[:deploy][application][:environment]["HOME"]}.merge(node[:deploy][application][:env])
  elsif node[:deploy][application][:environment] && node[:deploy][application][:environment]["HOME"]
    default[:nettyapp][application][:env] = {"HOME" => node[:deploy][application][:environment]["HOME"]}
  elsif node[:deploy][application][:env]
    default[:nettyapp][application][:env] = node[:deploy][application][:env]
  end

  default[:nettyapp][application][:restart_server_command] = "monit restart nettyapp_#{application}_server"
  default[:nettyapp][application][:stop_server_command] = "monit stop nettyapp_#{application}_server"

  default[:nettyapp][application][:config_file] = "#{node[:deploy][application][:deploy_to]}/shared/config/#{application}.properties"
  default[:nettyapp][application][:pid_file] = "#{node[:deploy][application][:deploy_to]}/shared/pids/nettyapp.pid"
  default[:nettyapp][application][:output_file] = "#{node[:deploy][application][:deploy_to]}/shared/log/nettyapp.log"
  default[:nettyapp][application][:test_url] = "/"

  if node[:deploy][application][:config]
    node[:deploy][application][:config].each do |name|
      default[:nettyapp][application][:config][name] = node[name]
    end
  end
end
