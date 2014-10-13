# AWS OpsWorks Recipe for Wordpress to be executed during the Deploy lifecycle phase
# - Creates the config file wp-config-local.php with MySQL data.
# - Allows uploads from apache

node[:deploy].each do |app_name, deploy|

  db_name = deploy[:database][:database] rescue nil
  db_user =  deploy[:database][:username] rescue nil
  db_password = deploy[:database][:password] rescue nil
  db_host = deploy[:database][:host] rescue nil

  # Check we have everything we need
  raise 'Database name cannot be empty.' if db_name.empty?
  raise 'Database username cannot be empty.' if db_user.empty?
  raise 'Database password cannot be empty.' if db_password.empty?
  raise 'Database host cannot be empty.' if db_host.empty?

  if platform?("ubuntu")
    httpuser = "www-data"
  elsif platform?("amazon")
    httpuser = "apache"
  end

  # Allow web server to create uploads
  # TODO: move to the 'symlinks' var in the deploy cookbook attributes
  bash 'Allow web server to create uploads' do
    upload_dir = "#{deploy[:deploy_to]}/shared/system/wp-content/uploads"
    target_dir = "#{deploy[:deploy_to]}/current/wp-content/uploads"

    code <<-EOH
      rm -rdf      #{target_dir}
      mkdir -p     #{upload_dir}
      mkdir g+w -R #{upload_dir}
      ln -sf       #{upload_dir} #{target_dir}
    EOH
  end

  template "#{deploy[:deploy_to]}/current/wp-config-local.php" do
    source "wp-config-local.php.erb"
    mode 0650
    owner 'deploy'
    group httpuser
    variables(
      :database   => db_name,
      :user       => db_user,
      :password   => db_password,
      :host       => db_host,
      :keys       => (keys rescue nil)
    )
  end


end
