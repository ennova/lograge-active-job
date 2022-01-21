lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lograge_active_job/version"

Gem::Specification.new do |spec|
  spec.name = "lograge_active_job"
  spec.version = LogrageActiveJob::VERSION
  spec.authors = ["Pervushin Alec"]
  spec.email = ["pervushin.oa@gmail.com"]

  spec.summary = "Lograge for ActiveJobs."
  spec.description = "Lograge for ActiveJobs."
  spec.homepage = "https://github.com/one0fnine/lograge_active_job"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 4"
  spec.add_runtime_dependency "railties", ">= 4"
  spec.add_runtime_dependency "lograge", "> 0.11"

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
