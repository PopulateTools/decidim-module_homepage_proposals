# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/homepage_proposals/version"

Gem::Specification.new do |s|
  s.version = Decidim::HomepageProposals.version
  s.authors = ["Elie Gaboriau"]
  s.email = ["elie@opensourcepolitics.eu"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-homepage_proposals"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-homepage_proposals"
  s.summary = "A decidim homepage_proposals module"
  s.description = "Homepage slider for proposals."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", "~> #{Decidim::HomepageProposals.decidim_version}"
  s.add_dependency "decidim-admin", "~> #{Decidim::HomepageProposals.decidim_version}"
  s.add_dependency "deface", ">= 1.5"

  s.metadata["rubygems_mfa_required"] = "true"
end
