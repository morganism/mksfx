# frozen_string_literal: true

require 'thor'

module Mksfx
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: 'Verbose output'
    
    def self.exit_on_failure?
      true
    end

    desc 'build SOURCE', 'Build a self-extracting archive from SOURCE directory'
    long_desc <<~DESC
      Build a portable, auditable self-extracting archive from a source directory.
      
      The source directory must contain a bootstrap.sh script (or specify with --entrypoint).
      
      Creates a single .tar.gz file containing:
        - POSIX shell installer (cross-platform)
        - Payload archive with SHA-256 verification
        - MANIFEST with version and checksum
      
      Examples:
        mksfx build ./my_app
        mksfx build ./my_app --output installer.tar.gz
        mksfx build ./my_app --version 2.1.0 --entrypoint install.sh
    DESC
    option :output, type: :string, aliases: '-o', desc: 'Output filename', default: 'installer.tar.gz'
    option :version, type: :string, desc: 'Payload version', default: '1.0.0'
    option :entrypoint, type: :string, aliases: '-e', desc: 'Bootstrap script name', default: 'bootstrap.sh'
    option :compression, type: :string, aliases: '-c', desc: 'Compression level (1-9)', default: '9'
    option :metadata, type: :hash, desc: 'Additional metadata key=value pairs'
    def build(source)
      validate_source!(source)
      
      builder = Builder.new(
        source,
        output_file: options[:output],
        version: options[:version],
        entrypoint: options[:entrypoint],
        compression: options[:compression].to_i,
        metadata: options[:metadata] || {},
        verbose: options[:verbose]
      )
      
      result = builder.build
      
      puts ""
      puts "✅ Self-extracting archive created!"
      puts ""
      puts "  📦 Output: #{result[:output]}"
      puts "  📊 Size: #{format_size(result[:size])}"
      puts "  🔐 Checksum: #{result[:checksum][0..15]}..."
      puts "  📝 Version: #{result[:version]}"
      puts ""
      puts "Verify and extract:"
      puts "  tar -tzf #{result[:output]}        # Inspect"
      puts "  tar -xzf #{result[:output]}        # Extract"
      puts "  cd bundle && sh installer.sh -h    # Help"
      puts ""
    rescue Mksfx::Error => e
      error "Build failed: #{e.message}"
      exit 1
    end

    desc 'update OLD NEW', 'Create incremental update from OLD to NEW version'
    long_desc <<~DESC
      Create an incremental update archive containing only the differences
      between two versions. This creates a much smaller update package.
      
      The update archive can be applied to the old version to create the new version.
      
      Examples:
        mksfx update app-v1.0.tar.gz app-v2.0.tar.gz
        mksfx update app-v1.0.tar.gz app-v2.0.tar.gz --output update-1.0-to-2.0.tar.gz
    DESC
    option :output, type: :string, aliases: '-o', desc: 'Output filename'
    option :algorithm, type: :string, aliases: '-a', desc: 'Delta algorithm (bsdiff/xdelta)', default: 'auto'
    def update(old_archive, new_archive)
      updater = Updater.new(
        old_archive,
        new_archive,
        output_file: options[:output],
        algorithm: options[:algorithm],
        verbose: options[:verbose]
      )
      
      result = updater.create_update
      
      puts ""
      puts "✅ Incremental update created!"
      puts ""
      puts "  📦 Output: #{result[:output]}"
      puts "  📊 Size: #{format_size(result[:size])}"
      puts "  📉 Savings: #{result[:savings_percent]}% vs full archive"
      puts "  🔄 Old: #{result[:old_version]} → New: #{result[:new_version]}"
      puts ""
      puts "Apply update:"
      puts "  tar -xzf #{result[:output]}"
      puts "  cd bundle && sh update.sh --apply"
      puts ""
    rescue Mksfx::Error => e
      error "Update creation failed: #{e.message}"
      exit 1
    end

    desc 'verify ARCHIVE', 'Verify integrity of a self-extracting archive'
    long_desc <<~DESC
      Verify the integrity of a self-extracting archive by:
        - Extracting and checking the embedded checksum
        - Validating the MANIFEST format
        - Ensuring the installer.sh is well-formed
      
      Examples:
        mksfx verify installer.tar.gz
        mksfx verify installer.tar.gz --verbose
    DESC
    def verify(archive)
      verifier = Builder.new(archive, verbose: options[:verbose])
      result = verifier.verify
      
      puts ""
      puts "✅ Archive verified successfully!"
      puts ""
      puts "  📦 File: #{archive}"
      puts "  🔐 Checksum: #{result[:checksum][0..15]}..."
      puts "  📝 Version: #{result[:version]}"
      puts "  🎯 Entrypoint: #{result[:entrypoint]}"
      puts ""
    rescue Mksfx::Error => e
      error "Verification failed: #{e.message}"
      exit 1
    end

    desc 'info ARCHIVE', 'Show information about a self-extracting archive'
    long_desc <<~DESC
      Display detailed information about a self-extracting archive including:
        - Version and metadata
        - Payload size and compression ratio
        - Embedded checksum
        - Entrypoint script
        - File listing
      
      Examples:
        mksfx info installer.tar.gz
        mksfx info installer.tar.gz --files
    DESC
    option :files, type: :boolean, desc: 'Show file listing'
    def info(archive)
      verifier = Builder.new(archive, verbose: options[:verbose])
      info = verifier.info
      
      puts ""
      puts "Archive Information: #{archive}"
      puts "─" * 60
      puts "Version:     #{info[:version]}"
      puts "Checksum:    #{info[:checksum]}"
      puts "Entrypoint:  #{info[:entrypoint]}"
      puts "Total Size:  #{format_size(info[:total_size])}"
      puts "Payload:     #{format_size(info[:payload_size])}"
      puts "Overhead:    #{format_size(info[:overhead])} (#{info[:overhead_percent]}%)"
      
      if info[:metadata] && !info[:metadata].empty?
        puts ""
        puts "Metadata:"
        info[:metadata].each do |key, value|
          puts "  #{key}: #{value}"
        end
      end
      
      if options[:files]
        puts ""
        puts "Files:"
        info[:files].each { |f| puts "  #{f}" }
      end
      puts ""
    rescue Mksfx::Error => e
      error "Info retrieval failed: #{e.message}"
      exit 1
    end

    desc 'version', 'Show mksfx version'
    def version
      puts "mksfx #{Mksfx::VERSION}"
    end

    desc 'init NAME', 'Create a new payload directory structure'
    long_desc <<~DESC
      Initialize a new payload directory with the required structure:
        - bootstrap.sh (installation script)
        - files/ (application files directory)
        - README.md (documentation template)
      
      Examples:
        mksfx init my_app
        mksfx init my_app --entrypoint install.sh
    DESC
    option :entrypoint, type: :string, aliases: '-e', desc: 'Bootstrap script name', default: 'bootstrap.sh'
    def init(name)
      dir = File.expand_path(name)
      
      if Dir.exist?(dir)
        error "Directory already exists: #{dir}"
        exit 1
      end
      
      FileUtils.mkdir_p(dir)
      FileUtils.mkdir_p(File.join(dir, 'files'))
      
      # Create bootstrap script
      bootstrap_path = File.join(dir, options[:entrypoint])
      File.write(bootstrap_path, bootstrap_template)
      FileUtils.chmod(0755, bootstrap_path)
      
      # Create README
      readme_path = File.join(dir, 'README.md')
      File.write(readme_path, readme_template(name))
      
      puts ""
      puts "✅ Payload directory initialized: #{name}"
      puts ""
      puts "Structure:"
      puts "  #{name}/"
      puts "  ├── #{options[:entrypoint]}  (installation script)"
      puts "  ├── files/         (your application files)"
      puts "  └── README.md      (documentation)"
      puts ""
      puts "Next steps:"
      puts "  1. Edit #{options[:entrypoint]} with your installation logic"
      puts "  2. Add files to files/ directory"
      puts "  3. Build: mksfx build #{name}"
      puts ""
    end

    private

    def validate_source!(source)
      unless Dir.exist?(source)
        raise BuildError, "Source directory not found: #{source}"
      end
    end

    def format_size(bytes)
      if bytes < 1024
        "#{bytes} B"
      elsif bytes < 1024 * 1024
        "#{(bytes / 1024.0).round(1)} KB"
      else
        "#{(bytes / 1024.0 / 1024.0).round(2)} MB"
      end
    end

    def error(message)
      $stderr.puts "\e[31m✗ #{message}\e[0m"
    end

    def bootstrap_template
      <<~'BOOTSTRAP'
        #!/bin/sh
        # Bootstrap installation script
        # This is executed when the user runs: sh installer.sh --run
        
        set -e  # Exit on error
        
        echo "╔═══════════════════════════════════════════╗"
        echo "║  Installation Started                     ║"
        echo "╚═══════════════════════════════════════════╝"
        echo ""
        
        # Get script directory
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
        
        # Example: Extract compressed files
        if [ -d "$SCRIPT_DIR/files" ]; then
          echo "📂 Processing files..."
          
          for gz_file in "$SCRIPT_DIR/files"/*.gz; do
            if [ -f "$gz_file" ]; then
              filename=$(basename "$gz_file" .gz)
              echo "  Extracting: $filename"
              gzip -dc "$gz_file" > "/tmp/$filename"
            fi
          done
        fi
        
        # Add your installation logic here
        echo ""
        echo "✅ Installation completed successfully!"
        echo ""
      BOOTSTRAP
    end

    def readme_template(name)
      <<~README
        # #{name}
        
        Self-extracting installer payload directory.
        
        ## Structure
        
        - `bootstrap.sh` - Installation script executed on `--run`
        - `files/` - Application files and resources
        
        ## Building
        
        ```bash
        mksfx build . -o #{name}-installer.tar.gz
        ```
        
        ## Testing
        
        ```bash
        tar -xzf #{name}-installer.tar.gz
        cd bundle
        sh installer.sh --verify
        sh installer.sh --extract
        sh installer.sh --run
        ```
        
        ## Distribution
        
        Distribute `#{name}-installer.tar.gz` to users.
      README
    end
  end
end
