# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Run tests'
task test: :spec

desc 'Run linter'
task lint: :rubocop

desc 'Run all checks (lint + test)'
task check: [:lint, :test]

desc 'Build and install gem locally'
task :install_local do
  sh 'gem build mksfx.gemspec'
  sh 'gem install mksfx-*.gem'
end

desc 'Clean build artifacts'
task :clean do
  sh 'rm -f *.gem'
  sh 'rm -rf pkg/'
end

task default: :check
