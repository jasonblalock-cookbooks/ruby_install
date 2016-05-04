include RubyInstall::OptionsHelper
include RubyInstall::UsersHelper
include RubyInstall::VersionsHelper
include RubyInstall::DependencyHelper

action :install do
  perform_install "no-reinstall" => nil
  new_resource.updated_by_last_action(true)
end

action :reinstall do
  perform_install
  new_resource.updated_by_last_action(true)
end

private

RUBY_INSTALL_OPTS = %w{rubies-dir src-dir patch mirror url md5 sha1 sha256 sha512 no-download no-verify no-install-deps}.freeze

def perform_install(options = {})
  register_options(options)

  if new_resource.user	  
    setup_user_defaults
    install_dependencies
    setup_gem_config
  else
    setup_system_defaults
  end

  execute_ruby_install

  install_gems if new_resource.gems
end

def register_options(options)
  # Register action options for ruby-install
  options.each { |k,v| install_options[k] = v }

  # Register ruby-install options
  RUBY_INSTALL_OPTS.each { |option| register_user_option(option) }
end

def setup_user_defaults
  unless install_options["src-dir"]
    # $HOME/rubies-src
    install_options["src-dir"] = ::File.join(user_home_dir, 'rubies-src')
  end

  unless install_options["rubies-dir"]
    # $HOME/.rubies/{ruby_string}
    install_options["rubies-dir"] = ::File.join(user_home_dir, ".rubies")
  end

  install_options["no-install-deps"] = true
end

def install_dependencies
  deps = ruby_install_deps(ruby_type)

  execute "apt-get-update" do
    command "apt-get update"
    ignore_failure true
    only_if do
      !::File.exists?('/var/lib/apt/periodic/update-success-stamp') ||
      ::File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
    end
  end

  package deps
end

def setup_system_defaults
  unless install_options["rubies-dir"]
    # /opt/rubies/{ruby_string}
    install_options["rubies-dir"] = ::File.join('/opt', 'rubies')
  end
end

def execute_ruby_install
  execute "ruby-install[#{new_resource.ruby}]" do
    command <<-EOH
      /usr/local/bin/ruby-install #{new_resource.ruby} \
        #{stringify_install_options}
    EOH
    user new_resource.user if new_resource.user
    group new_resource.group if new_resource.group
    environment new_resource.environment if new_resource.environment
  end
end

def setup_gem_config
  template ::File.join(user_home_dir, '.gemrc') do
    source 'gemrc.erb'
    owner new_resource.user
    group new_resource.group
    mode '0664'
    cookbook 'ruby_install'
    action :create
    only_if do new_resource.user end
  end
end

def install_gems
  new_resource.gems.each do |gem_config|
    gem_path = ::File.join(install_options["rubies-dir"], fq_ruby, "bin/gem")
    gem_config = gem_config.dup # So we can delete entries from hash

    gem_package gem_config.delete(:name) do
      gem_binary gem_path
      version gem_config.delete(:version)
    end
  end
end


def ruby_type
  @_ruby_type ||= parse_ruby(new_resource.ruby).first
end

def fq_ruby
  @_fq_ruby ||= fully_qualified_ruby(new_resource.ruby)
end

