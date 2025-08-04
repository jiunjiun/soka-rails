# frozen_string_literal: true

require_relative 'lib/soka/rails/version'

Gem::Specification.new do |spec|
  spec.name = 'soka-rails'
  spec.version = Soka::Rails::VERSION
  spec.authors = ['jiunjiun']
  spec.email = ['imjiunjiun@gmail.com']

  spec.summary = 'Rails integration for Soka AI Agent Framework'
  spec.description = 'Soka Rails provides seamless integration between the Soka AI Agent Framework ' \
                     'and Ruby on Rails applications, following Rails conventions for easy adoption.'
  spec.homepage = 'https://github.com/jiunjiun/soka-rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jiunjiun/soka-rails'
  spec.metadata['changelog_uri'] = 'https://github.com/jiunjiun/soka-rails/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github/ appveyor Gemfile])
    end
  end

  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'rails', '>= 7.0', '< 9.0'
  spec.add_dependency 'soka', '~> 0.0.3'
  spec.add_dependency 'zeitwerk', '~> 2.6'
end
