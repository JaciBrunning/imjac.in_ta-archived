require 'rack'
$:.unshift File.dirname(__FILE__)

require 'webcore/webcore'
require 'webcore/loader/loader'
require 'webcore/routing/middleware'

WEBROOT = File.dirname(__FILE__)

WEBCORE = Webcore::Webcore.new WEBROOT
LOADER = Webcore::Loader.new([ "#{WEBROOT}/modules", "." ])

LOADER.run! WEBCORE

puts "Starting..."
use Webcore::Middleware, WEBCORE.domains

run Proc.new { |env| [404, {}, ['Not Found']] }