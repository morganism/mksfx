# frozen_string_literal: true

require_relative 'lib/mksfx/version'

Gem::Specification.new do |spec|
  spec.name = 'mksfx'
  spec.version = Mksfx::VERSION
  spec.authors = ['Morgan']
  spec.email = ['']
  
  spec.summary = 'Create portable, auditable self-extracting archives'
  spec.description = <<~DESC
    mksfx creates portable, auditable self-extracting archives with POSIX shell installers.
    No magic. No implicit execution. Pure Unix.
    
    Features:
    - POSIX shell installer (Linux/macOS compatible)
    - SHA-256 integrity verification
    - Interactive or non-interactive modes
    - Incremental update support
    - No runtime dependencies beyond POSIX + tar/gzip
  DESC
  
  spec.homepage = 'https://github.com/morganism/mksfx'
  spec.license = 'Unlicense'
  spec.required_ruby_version = '>= 2.7.0'
  
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/morganism/mksfx'
  spec.metadata['changelog_uri'] = 'https://github.com/morganism/mksfx/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/morganism/mksfx/issues'
  
  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob('{bin,lib}/**/*') + %w[
    README.md
    LICENSE
    CHANGELOG.md
  ]
  
  spec.bindir = 'bin'
  spec.executables = ['mksfx']
  spec.require_paths = ['lib']
  
  # Runtime dependencies
  spec.add_dependency 'thor', '~> 1.3'
  
  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
end
