# frozen_string_literal: true

# This file serves as the entry point for the soka-rails gem
# It ensures proper loading order for Rails integration

require 'rails'
require 'soka'
require 'zeitwerk'

# Load the main Soka::Rails module
require_relative 'soka/rails'
