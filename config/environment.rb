# require 'bundler'

# Bundler.require(:default)

require 'set'
require 'oj'
require 'benchmark'

$LOAD_PATH << File.expand_path('lib', __dir__)

Dir[Dir.pwd + '/lib/**/*.rb'].each do |file|
  require file
end
