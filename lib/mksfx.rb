# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'tmpdir'
require 'zlib'

require_relative 'mksfx/version'
require_relative 'mksfx/builder'
require_relative 'mksfx/updater'
require_relative 'mksfx/cli'

module Mksfx
  class Error < StandardError; end
  class BuildError < Error; end
  class UpdateError < Error; end
  class ValidationError < Error; end
end
