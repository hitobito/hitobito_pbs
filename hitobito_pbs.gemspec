$:.push File.expand_path("../lib", __FILE__)

# Maintain your wagon's version:
require "hitobito_pbs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hitobito_pbs"
  s.version     = HitobitoPbsc::VERSION
  s.authors     = ["Andreas Maierhofer"]
  s.email       = ["maierhofer@puzzle.ch"]
  s.summary     = "Pfadi organization specific features"
  s.description = "Pfadi organization specific features"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["spec/**/*"]
end
