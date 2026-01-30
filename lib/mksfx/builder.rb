# frozen_string_literal: true

module Mksfx
  class Builder
    attr_reader :source_dir, :output_file, :version, :entrypoint, :metadata

    def initialize(source, output_file: nil, version: '1.0.0', entrypoint: 'bootstrap.sh',
                   compression: 9, metadata: {}, verbose: false)
      @source_dir = File.expand_path(source)
      @output_file = output_file || 'installer.tar.gz'
      @version = version
      @entrypoint = entrypoint
      @compression = compression
      @metadata = metadata
      @verbose = verbose
      
      validate_source!
    end

    def build
      Dir.mktmpdir do |tmpdir|
        bundle_dir = File.join(tmpdir, 'bundle')
        payload_dir = File.join(tmpdir, 'payload')
        
        FileUtils.mkdir_p(bundle_dir)
        FileUtils.mkdir_p(payload_dir)
        
        log "📦 Copying source files..."
        FileUtils.cp_r(Dir.glob(File.join(@source_dir, '*')), payload_dir)
        
        log "📝 Generating MANIFEST..."
        manifest_path = File.join(payload_dir, 'MANIFEST')
        create_manifest(manifest_path)
        
        log "🗜️  Creating payload.tar.gz (compression: #{@compression})..."
        payload_tarball = File.join(bundle_dir, 'payload.tar.gz')
        create_payload_tarball(payload_dir, payload_tarball)
        
        log "🔐 Calculating checksum..."
        payload_checksum = calculate_checksum(payload_tarball)
        
        log "♻️  Updating MANIFEST with checksum..."
        update_manifest_checksum(manifest_path, payload_checksum)
        
        log "🔄 Recreating payload with updated MANIFEST..."
        FileUtils.rm(payload_tarball)
        create_payload_tarball(payload_dir, payload_tarball)
        
        log "🔐 Calculating final checksum..."
        final_checksum = calculate_checksum(payload_tarball)
        
        log "⚙️  Generating installer.sh..."
        installer_path = File.join(bundle_dir, 'installer.sh')
        create_installer(installer_path, final_checksum)
        
        log "📚 Creating final bundle..."
        create_final_bundle(bundle_dir, @output_file)
        
        bundle_size = File.size(@output_file)
        payload_size = File.size(payload_tarball)
        
        {
          output: @output_file,
          size: bundle_size,
          payload_size: payload_size,
          overhead: bundle_size - payload_size,
          overhead_percent: (((bundle_size - payload_size).to_f / payload_size) * 100).round(2),
          checksum: final_checksum,
          version: @version,
          entrypoint: @entrypoint
        }
      end
    end

    def verify
      # TODO: Implement verification logic
      raise NotImplementedError, "Verification not yet implemented"
    end

    def info
      # TODO: Implement info extraction
      raise NotImplementedError, "Info extraction not yet implemented"
    end

    private

    def validate_source!
      unless Dir.exist?(@source_dir)
        raise BuildError, "Source directory not found: #{@source_dir}"
      end
      
      entrypoint_path = File.join(@source_dir, @entrypoint)
      unless File.exist?(entrypoint_path)
        raise BuildError, "Entrypoint script not found: #{entrypoint_path}"
      end
    end

    def create_manifest(path)
      metadata_lines = @metadata.map { |k, v| "#{k}: #{v}" }.join("\n")
      
      manifest_content = <<~MANIFEST
        Payload-Version: #{@version}
        Payload-Checksum: PLACEHOLDER
        Bootstrap-Entrypoint: #{@entrypoint}
      MANIFEST
      
      manifest_content += metadata_lines + "\n" unless metadata_lines.empty?
      
      File.write(path, manifest_content)
    end

    def update_manifest_checksum(path, checksum)
      content = File.read(path)
      content.sub!(/Payload-Checksum: PLACEHOLDER/, "Payload-Checksum: SHA256:#{checksum}")
      File.write(path, content)
    end

    def create_payload_tarball(source_dir, output_file)
      Dir.chdir(File.dirname(source_dir)) do
        basename = File.basename(source_dir)
        result = system(
          "tar", "-czf", output_file, 
          "--options", "gzip:compression-level=#{@compression}",
          basename,
          out: File::NULL, err: File::NULL
        )
        raise BuildError, "Failed to create payload tarball" unless result
      end
    end

    def create_final_bundle(bundle_dir, output_file)
      Dir.chdir(File.dirname(bundle_dir)) do
        basename = File.basename(bundle_dir)
        result = system(
          "tar", "-czf", output_file,
          "--options", "gzip:compression-level=#{@compression}",
          basename,
          out: File::NULL, err: File::NULL
        )
        raise BuildError, "Failed to create final bundle" unless result
      end
    end

    def calculate_checksum(file)
      Digest::SHA256.hexdigest(File.binread(file))
    end

    def create_installer(path, checksum)
      template_path = File.join(__dir__, 'templates', 'installer.sh.erb')
      
      # For now, use inline template. TODO: Move to ERB template file
      File.write(path, installer_template(checksum))
      File.chmod(0755, path)
    end

    def installer_template(checksum)
      File.read(File.join(__dir__, 'templates', 'installer.sh'))
        .sub('EMBEDDED_CHECKSUM="PLACEHOLDER"', "EMBEDDED_CHECKSUM=\"#{checksum}\"")
    end

    def log(message)
      puts message if @verbose
    end
  end
end
