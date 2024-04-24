lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lograge/active_job/version"

Gem::Specification.new do |spec|
  spec.name = "lograge-active-job"
  spec.version = Lograge::ActiveJob::VERSION
  spec.authors = ["Pervushin Alec"]
  spec.email = ["pervushin.oa@gmail.com"]

  spec.summary = "Lograge for ActiveJob."
  spec.description = "Lograge for ActiveJob."
  spec.homepage = "https://github.com/one0fnine/lograge-active-job"
  spec.license = "MIT"

  spec.files = Dir["lib/**/*", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.add_runtime_dependency "activejob", ">= 5", "< 7.2"
  spec.add_runtime_dependency "lograge", "> 0.11"

  spec.add_development_dependency "rake", ">= 12.3.3"
end
