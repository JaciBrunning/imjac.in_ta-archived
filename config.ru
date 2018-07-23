require 'rack'
$:.unshift File.dirname(__FILE__)

require 'webcore/webcore'
require 'webcore/loader/loader'
require 'webcore/routing/middleware'

WEBROOT = File.dirname(__FILE__)

WEBCORE = Webcore::Webcore.new WEBROOT, "imjac.in"

SEARCHPATHS = [ "#{WEBROOT}/modules", ".", "~/webcore/modules"] + (ENV["WEBCORE_MODULE_PATH"] || "").split(";")
LOADER = Webcore::Loader.new(SEARCHPATHS)

LOADER.run! WEBCORE

puts "[RACKUP] Starting..."
use Webcore::Middleware, WEBCORE.domains

run Proc.new { |env| [404, {}, ['Not Found']] }