# frozen_string_literal: true

source "https://rubygems.org"
base_path = File.basename(__dir__) == "development_app" ? "../" : ""
require_relative "#{base_path}lib/decidim/homepage_proposals/version"

DECIDIM_VERSION = Decidim::HomepageProposals.decidim_version

ruby RUBY_VERSION

gem "decidim", "~> #{DECIDIM_VERSION}"
gem "decidim-homepage_proposals", path: "."

gem "bootsnap", "~> 1.4"

gem "puma", ">= 5.6.2"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", "~> #{DECIDIM_VERSION}"
  gem "rubocop-faker", "~> 1.1"
  gem "deface", ">= 1.5"
end

group :development do
  gem "faker", "~> 3.2"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rack-mini-profiler", require: false
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end
