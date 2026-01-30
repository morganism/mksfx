# frozen_string_literal: true

module Mksfx
  class Updater
    attr_reader :old_archive, :new_archive, :output_file

    def initialize(old_archive, new_archive, output_file: nil, algorithm: 'auto', verbose: false)
      @old_archive = File.expand_path(old_archive)
      @new_archive = File.expand_path(new_archive)
      @output_file = output_file || generate_update_filename
      @algorithm = algorithm
      @verbose = verbose
      
      validate_archives!
    end

    def create_update
      Dir.mktmpdir do |tmpdir|
        old_dir = File.join(tmpdir, 'old')
        new_dir = File.join(tmpdir, 'new')
        update_dir = File.join(tmpdir, 'update')
        
        # Extract both archives
        log "📦 Extracting old archive..."
        extract_archive(@old_archive, old_dir)
        
        log "📦 Extracting new archive..."
        extract_archive(@new_archive, new_dir)
        
        # Get payload directories
        old_payload = File.join(old_dir, 'bundle', 'payload')
        new_payload = File.join(new_dir, 'bundle', 'payload')
        
        # Extract payloads if not already done
        unless Dir.exist?(old_payload)
          extract_payload(File.join(old_dir, 'bundle', 'payload.tar.gz'), old_dir)
        end
        
        unless Dir.exist?(new_payload)
          extract_payload(File.join(new_dir, 'bundle', 'payload.tar.gz'), new_dir)
        end
        
        # Calculate differences
        log "🔍 Calculating differences..."
        delta = calculate_delta(old_payload, new_payload)
        
        # Create update package
        log "📝 Creating update package..."
        FileUtils.mkdir_p(update_dir)
        create_update_package(update_dir, delta)
        
        # Get version info
        old_version = extract_version(File.join(old_payload, 'MANIFEST'))
        new_version = extract_version(File.join(new_payload, 'MANIFEST'))
        
        # Package update
        log "🗜️  Packaging update..."
        package_update(update_dir, @output_file)
        
        # Calculate savings
        new_size = File.size(@new_archive)
        update_size = File.size(@output_file)
        savings = ((1 - (update_size.to_f / new_size)) * 100).round(2)
        
        {
          output: @output_file,
          size: update_size,
          full_size: new_size,
          savings: new_size - update_size,
          savings_percent: savings,
          old_version: old_version,
          new_version: new_version,
          files_changed: delta[:changed].size,
          files_added: delta[:added].size,
          files_removed: delta[:removed].size
        }
      end
    end

    private

    def validate_archives!
      unless File.exist?(@old_archive)
        raise UpdateError, "Old archive not found: #{@old_archive}"
      end
      
      unless File.exist?(@new_archive)
        raise UpdateError, "New archive not found: #{@new_archive}"
      end
    end

    def extract_archive(archive, dest_dir)
      FileUtils.mkdir_p(dest_dir)
      system("tar", "-xzf", archive, "-C", dest_dir, out: File::NULL, err: File::NULL)
    end

    def extract_payload(payload_gz, dest_dir)
      system("tar", "-xzf", payload_gz, "-C", dest_dir, out: File::NULL, err: File::NULL)
    end

    def calculate_delta(old_dir, new_dir)
      old_files = list_files(old_dir)
      new_files = list_files(new_dir)
      
      added = new_files - old_files
      removed = old_files - new_files
      common = old_files & new_files
      
      changed = common.select do |file|
        old_path = File.join(old_dir, file)
        new_path = File.join(new_dir, file)
        !files_identical?(old_path, new_path)
      end
      
      {
        added: added.map { |f| File.join(new_dir, f) },
        removed: removed,
        changed: changed.map { |f| File.join(new_dir, f) }
      }
    end

    def list_files(dir)
      Dir.glob("**/*", base: dir)
        .reject { |f| File.directory?(File.join(dir, f)) }
    end

    def files_identical?(file1, file2)
      return false unless File.size(file1) == File.size(file2)
      Digest::SHA256.file(file1) == Digest::SHA256.file(file2)
    end

    def create_update_package(update_dir, delta)
      # Create directories structure
      FileUtils.mkdir_p(File.join(update_dir, 'files', 'added'))
      FileUtils.mkdir_p(File.join(update_dir, 'files', 'changed'))
      
      # Copy added files
      delta[:added].each do |src|
        relative = src.sub(%r{.*/payload/}, '')
        dest = File.join(update_dir, 'files', 'added', relative)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
      end
      
      # Copy changed files
      delta[:changed].each do |src|
        relative = src.sub(%r{.*/payload/}, '')
        dest = File.join(update_dir, 'files', 'changed', relative)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
      end
      
      # Create manifest
      create_update_manifest(update_dir, delta)
      
      # Create update script
      create_update_script(update_dir)
    end

    def create_update_manifest(update_dir, delta)
      manifest = {
        'Update-Type' => 'incremental',
        'Files-Added' => delta[:added].size,
        'Files-Changed' => delta[:changed].size,
        'Files-Removed' => delta[:removed].size,
        'Removed-Files' => delta[:removed].join("\n")
      }
      
      File.write(File.join(update_dir, 'UPDATE_MANIFEST'), 
                 manifest.map { |k, v| "#{k}: #{v}" }.join("\n"))
    end

    def create_update_script(update_dir)
      script = <<~'SCRIPT'
        #!/bin/sh
        # Incremental update script
        set -e
        
        PAYLOAD_DIR="${PAYLOAD_DIR:-../payload}"
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
        
        echo "Applying incremental update..."
        
        # Apply added files
        if [ -d "$SCRIPT_DIR/files/added" ]; then
          echo "  Adding new files..."
          cp -r "$SCRIPT_DIR/files/added"/* "$PAYLOAD_DIR/"
        fi
        
        # Apply changed files
        if [ -d "$SCRIPT_DIR/files/changed" ]; then
          echo "  Updating changed files..."
          cp -r "$SCRIPT_DIR/files/changed"/* "$PAYLOAD_DIR/"
        fi
        
        # Remove deleted files
        if grep -q "^Removed-Files:" "$SCRIPT_DIR/UPDATE_MANIFEST"; then
          echo "  Removing deleted files..."
          sed -n '/^Removed-Files:/,/^$/p' "$SCRIPT_DIR/UPDATE_MANIFEST" | \
            tail -n +2 | while read file; do
            [ -n "$file" ] && rm -f "$PAYLOAD_DIR/$file"
          done
        fi
        
        echo "✅ Update applied successfully!"
      SCRIPT
      
      script_path = File.join(update_dir, 'update.sh')
      File.write(script_path, script)
      File.chmod(0755, script_path)
    end

    def package_update(update_dir, output_file)
      Dir.chdir(File.dirname(update_dir)) do
        basename = File.basename(update_dir)
        system("tar", "-czf", output_file, basename, out: File::NULL, err: File::NULL)
      end
    end

    def extract_version(manifest_file)
      return 'unknown' unless File.exist?(manifest_file)
      
      File.readlines(manifest_file).each do |line|
        return $1 if line =~ /^Payload-Version:\s*(.+)$/
      end
      
      'unknown'
    end

    def generate_update_filename
      old_version = extract_version_from_archive(@old_archive)
      new_version = extract_version_from_archive(@new_archive)
      "update-#{old_version}-to-#{new_version}.tar.gz"
    end

    def extract_version_from_archive(archive)
      # Simple version extraction from filename
      if archive =~ /(\d+\.\d+\.\d+)/
        $1
      else
        Time.now.strftime('%Y%m%d')
      end
    end

    def log(message)
      puts message if @verbose
    end
  end
end
