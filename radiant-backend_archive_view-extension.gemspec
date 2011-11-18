# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-backend_archive_view-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-backend_archive_view-extension"
  s.version     = RadiantBackendArchiveViewExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantBackendArchiveViewExtension::AUTHORS
  s.email       = RadiantBackendArchiveViewExtension::EMAIL
  s.homepage    = RadiantBackendArchiveViewExtension::URL
  s.summary     = RadiantBackendArchiveViewExtension::SUMMARY
  s.description = RadiantBackendArchiveViewExtension::DESCRIPTION

  s.add_dependency "radiant",    ">= 1.0.0.rc3"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
end