# frozen_string_literal: true

require "lograge/log_subscribers/active_job"
require "logger"
require "active_job"

class UserJob < ActiveJob::Base
end

class UserModel
  include GlobalID::Identification

  def self.find(id)
    new
  end

  def id
    "user-id-42"
  end
end

RSpec.describe Lograge::LogSubscribers::ActiveJob do
  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end

  let(:subscriber) { described_class.new }
  let(:event_params) { {} }
  let(:mailer) { ActionMailer::Base }

  let(:event) do
    ActiveSupport::Notifications::Event.new(
      "perform.active_job",
      Time.now,
      Time.now + 1,
      1,
      payload
    )
  end
  let(:payload) { {adapter: ActiveJob::QueueAdapters::AsyncAdapter.new, job: job} }
  let(:job) { UserJob.new("args", model) }
  let(:model) { UserModel.new }

  before do
    Lograge.logger = logger
    Lograge.formatter = Lograge::Formatters::KeyValue.new
  end

  shared_examples "expect default fields with status" do |status|
    it "includes status" do
      expect(log_output.string).to include("status=#{status}")
    end

    it "includes job class" do
      expect(log_output.string).to include("job_class=#{job.class.name} ")
    end

    it "includes job id" do
      expect(log_output.string).to include("job_id=#{job.job_id}")
    end

    it "includes args" do
      expect(log_output.string).to include("args=args, #{model.to_global_id}")
    end

    it "includes adapter" do
      expect(log_output.string).to include("adapter=Async")
    end

    it "includes queue_name" do
      expect(log_output.string).to include("queue_name=default")
    end
  end

  context "when performed an action with lograge output" do
    before { subscriber.perform(event) }

    include_examples "expect default fields with status", "performed"
  end

  context "when perform started an action with lograge output" do
    before { subscriber.perform_start(event) }

    include_examples "expect default fields with status", "performing"
  end

  context "when enqueued an action with lograge output" do
    before { subscriber.enqueue(event) }

    include_examples "expect default fields with status", "enqueued"
  end

  context "when enqueue retried an action with lograge output" do
    let(:payload) { {adapter: ActiveJob::QueueAdapters::AsyncAdapter.new, job: job, wait: 1} }

    before { subscriber.enqueue_retry(event) }

    include_examples "expect default fields with status", "retrying"

    it "includes retry_in" do
      expect(log_output.string).to include("retry_in=1")
    end
  end

  context "when enqueue retried an action with lograge output" do
    before { subscriber.discard(event) }

    include_examples "expect default fields with status", "failed"
  end
end
