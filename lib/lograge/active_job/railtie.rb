# frozen_string_literal: true

require "active_support"
require "active_support/ordered_options"
require "rails/railtie"

module Lograge
  module ActiveJob
    class Railtie < Rails::Railtie
      config.lograge = ActiveSupport::OrderedOptions.new unless config.respond_to?(:lograge)
      config.lograge.active_job = ActiveSupport::OrderedOptions.new
      config.lograge.active_job.enabled = false
      config.lograge.active_job.ignore_events = []

      config.after_initialize do |app|
        Lograge::ActiveJob.setup(app) if app.config.lograge.active_job.enabled
      end
    end
  end
end
