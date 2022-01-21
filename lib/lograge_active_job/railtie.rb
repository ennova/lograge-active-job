# frozen_string_literal: true

require "rails/railtie"
require "lograge_active_job/ordered_options"

module LogrageActiveJob
  class Railtie < Rails::Railtie
    config.lograge.active_job = LogrageActiveJob::OrderedOptions.new
    config.lograge.active_job.enabled = false
    config.lograge.active_job.ignore_events = []

    config.after_initialize do |app|
      LogrageActiveJob.setup(app) if app.config.lograge.active_job.enabled
    end
  end
end
