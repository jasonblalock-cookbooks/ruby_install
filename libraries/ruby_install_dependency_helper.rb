module RubyInstall
  module DependencyHelper

    RUBY = {
      apt: %w{build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev}.freeze
    }.freeze

    JRUBY = {
      apt: %w{openjdk-7-jdk}.freeze
    }.freeze

    MAGLEV = {
      apt: [].freeze
    }.freeze

    MRUBY = {
      apt: %w{build-essential bison}.freeze
    }.freeze

    RBX = {
      apt: %w{gcc g++ automake flex bison ruby1.9.1-dev llvm-3.5-dev libedit-dev zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev}.freeze
    }.freeze

    def ruby_install_deps(ruby)
      package_manager = platform_package_manager

      return RubyInstall::DependencyHelper.const_get(ruby.upcase)[package_manager] if %w{jruby maglev mruby rbx ruby}.include?(ruby.downcase)
      Chef::Log.fatal("Could not find a matching ruby for dependency lookup")
      raise
    end

    def platform_package_manager
      case node[:platform]
      when 'ubuntu', 'debian'
        return :apt
      end
    end
  end
end
