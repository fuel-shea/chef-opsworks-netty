define :nettyapp_deploy_config_and_monit do
  # application_name
  # revision
  # nettyapp_application_settings
  # hostname
  # deploy_to
  # env_vars
  # config_vars
  # monit_conf_dir
  # group
  # user
  # custom_config_path

  service 'monit' do
    action :nothing
  end

  template "#{params[:config_file]}" do
    source  'config.properties.erb'
    mode    '0660'
    owner    params[:user]
    group    params[:group]
    variables(
      :application_name => params[:application_name],
      :deploy_path      => params[:deploy_to],
      :env_vars         => params[:env_vars],
      :config_vars      => params[:config_vars],
      :revision         => params[:revision]
    )
  end

  template "#{params[:deploy_to]}/current/nettyapp-#{params[:application_name]}-server-daemon" do
    source   'nettyapp-server-daemon.erb'
    owner    params[:user]
    group    params[:group]
    mode     '0751'
    variables(
      :deploy_to        => params[:deploy_to],
      :pid_file         => params[:nettyapp_application_settings][:pid_file],
      :release_path     => "#{params[:deploy_to]}/current",
      :application_name => params[:application_name],
    )

    only_if do
      File.exists?("#{params[:deploy_to]}/current")
    end
  end

  # Commenting this out until proper logging is actually in place.
  # Currently, we're just redirecting STDOUT/ERR to a file.
  #template "/etc/logrotate.d/#{params[:application_name]}" do
    #source   'logrotate.erb'
    #owner    'root'
    #group    'root'
    #mode     '0644'
    #variables(
        #:deploy_to        => params[:deploy_to],
        #:application_name => params[:application_name]
    #)
  #end

  bash "set up go application to use ports 80 and 443" do
    user "root"
    cwd "/tmp"
    code <<-EOH
      setcap 'cap_net_bind_service=+ep' $(readlink -f #{params[:deploy_to]}/current/bin/nettyapp_#{params[:application_name]}_server)
    EOH
  end

  template "#{params[:monit_conf_dir]}/nettyapp_#{params[:application_name]}_server.monitrc" do
    source  'nettyapp_server.monitrc.erb'
    owner   'root'
    group   'root'
    mode    '0644'
    variables(
      :deploy_to        => params[:deploy_to],
      :application_name => params[:application_name],
      :release_path     => "#{params[:deploy_to]}/current",
      :port             => params[:env_vars]['PORT'],
      :test_url         => params[:test_url]
    )

    only_if do
      File.exists?("#{params[:deploy_to]}/current")
    end

    notifies :restart, resources(:service => 'monit'), :immediately
  end
end
