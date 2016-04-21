module RubyInstall
  module VersionsHelper

    def ruby_versions_cache
      File.join(Chef::Config[:file_cache_path],'ruby_install', 'versions')
    end

    def ruby_versions_files
      %w{versions.txt stable.txt}
    end

    def ruby_versions_url
      'https://raw.githubusercontent.com/postmodern/ruby-versions/master/'
    end

    def parse_ruby(ruby_version)
      return ruby_version.split(' ', 2) if ruby_version.strip.include?(' ')
      ruby_version.split('-', 2)
    end

    def fully_qualified_ruby(ruby)
      ruby_type, version = parse_ruby(ruby)
      fq_version = lookup_ruby_version(ruby_type, version)
      "#{ruby_type.to_s.strip}-#{fq_version.to_s.strip}"
    end

    def lookup_ruby_version(ruby, version, force_update = false)
      download_ruby_versions(ruby) if force_update || ruby_versions_missing?(ruby)

      return version if known_ruby_version?(ruby, version)
      latest_ruby_version(ruby, version)
    end

    def known_ruby_version?(ruby, version)
      file = File.join(ruby_versions_cache, ruby, 'versions.txt')
      File.readlines(file).grep(/^#{version}$/).any?
    end
    
    def latest_ruby_version(ruby, version)
      file = File.join(ruby_versions_cache, ruby, 'stable.txt')
      lines = File.readlines(file)
      return lines.last if (version.nil? || version.empty?)
      lines.reverse_each.find { |i| i =~ /^(#{version})?(\..+|-.+)$/ }
    end
    
    def ruby_versions_missing?(ruby)
      ruby_versions_files.each do |file|
        return true unless File.exist?("#{ruby_versions_cache}/#{ruby}/#{file}")
      end
      false
    end

    def download_ruby_versions(ruby)
      directory = Chef::Resource::Directory.new(File.join(ruby_versions_cache, ruby), run_context)
      directory.recursive(true)
      directory.owner('root')
      directory.group('root')
      directory.mode('0755')
      directory.run_action(:create)
      ruby_versions_files.each { |file| download_ruby_versions_file(ruby, file) }
    end

    def download_ruby_versions_file(ruby, file)
      remote_file = Chef::Resource::RemoteFile.new(File.join(ruby_versions_cache, ruby, file), run_context)
      remote_file.source(URI.join(ruby_versions_url, "#{ruby}/", file).to_s)
      remote_file.owner('root')
      remote_file.group('root')
      remote_file.mode('0755')
      remote_file.use_last_modified(false)
      remote_file.run_action(:create)
      true
    end
  end
end
