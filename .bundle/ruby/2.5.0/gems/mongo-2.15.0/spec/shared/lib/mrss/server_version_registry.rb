# frozen_string_literal: true
# encoding: utf-8

autoload :JSON, 'json'
require 'open-uri'

module Mrss
  class ServerVersionRegistry
    class Error < StandardError
    end

    class UnknownVersion < Error
    end

    class MissingDownloadUrl < Error
    end

    class BrokenDownloadUrl < Error
    end

    def initialize(desired_version, arch)
      @desired_version, @arch = desired_version, arch
    end

    attr_reader :desired_version, :arch

    def download_url
      @download_url ||= begin
        version, version_ok = detect_version(current_catalog)
        if version.nil?
          version, full_version_ok = detect_version(full_catalog)
          version_ok ||= full_version_ok
        end
        if version.nil?
          if version_ok
            raise MissingDownloadUrl, "No downloads for version #{desired_version}"
          else
            raise UnknownVersion, "No version #{desired_version}"
          end
        end
        dl = version['downloads'].detect do |dl|
          dl['archive']['url'].index("enterprise-#{arch}") &&
          dl['arch'] == 'x86_64'
        end
        unless dl
          raise MissingDownloadUrl, "No download for #{arch} for #{version['version']}"
        end
        url = dl['archive']['url']
      end
    rescue MissingDownloadUrl
      if %w(4.7 4.7.0).include?(desired_version)
        # 4.7.0 has no advertised downloads but it is downloadable and
        # we do need it. Dirty hack below.
        registry = self.class.new('4.4.3', arch)
        registry.download_url.sub('4.4.3', '4.7.0').tap do |url|
          # Sanity check - ensure the URL we hacked up is a valid one
          io = uri_open(url)
          begin
            io.read(1)
          ensure
            io.close
          end
        end
      else
        raise
      end
    end

    private

    def uri_open(*args)
      if RUBY_VERSION < '2.5'
        open(*args)
      else
        URI.open(*args)
      end
    end

    def detect_version(catalog)
      candidate_versions = catalog['versions'].select do |version|
        version['version'].start_with?(desired_version) &&
        !version['version'].include?('-')
      end
      version_ok = !candidate_versions.empty?
      # Sometimes the download situation is borked and there is a release
      # with no downloads... skip those.
      version = candidate_versions.detect do |version|
        !version['downloads'].empty?
      end
      # Allow RC releases if there isn't a GA release.
      if version.nil?
        candidate_versions = catalog['versions'].select do |version|
          version['version'].start_with?(desired_version)
        end
        version_ok ||= !candidate_versions.empty?
        version = candidate_versions.detect do |version|
          !version['downloads'].empty?
        end
      end
      [version, version_ok]
    end

    def current_catalog
      @current_catalog ||= begin
        JSON.load(uri_open('http://downloads.mongodb.org/current.json').read)
      end
    end

    def full_catalog
      @full_catalog ||= begin
        JSON.load(uri_open('http://downloads.mongodb.org/full.json').read)
      end
    end
  end
end
