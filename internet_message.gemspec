Gem::Specification.new do |spec|
  spec.authors = 'TOMITA Masahiro'
  spec.email = 'tommy@tmtm.org'
  spec.files = Dir.glob(['lib/**/*.rb', 'spec/**/*.rb'])
  spec.homepage = 'http://github.com/tmtm/internet_message'
  spec.license = 'Ruby\'s'
  spec.name = 'internet_message'
  spec.required_ruby_version = '>= 1.9.2'
  spec.summary = 'Internet Message (RFC5322) parser'
  spec.description = 'InternetMessage is a parser for Internet Message (RFC5322)'
  spec.test_files = Dir.glob('spec/*_spec.rb')
  spec.version = '0.1'
  spec.add_dependency 'mmapscanner'
end
