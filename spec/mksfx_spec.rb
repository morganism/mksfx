# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mksfx do
  it 'has a version number' do
    expect(Mksfx::VERSION).not_to be nil
  end

  describe Mksfx::Builder do
    it 'raises error for non-existent source directory' do
      expect {
        Mksfx::Builder.new('/nonexistent/path')
      }.to raise_error(Mksfx::BuildError, /Source directory not found/)
    end
  end
end
