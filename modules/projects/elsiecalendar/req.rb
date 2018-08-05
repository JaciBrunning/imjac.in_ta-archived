require "net/http"
require "uri"
require "base64"
require "securerandom"
require "json"

class ElsieRequests
    AGENT = "elsie-android-1.9.1-1-PRD"
    BASE_URL = "https://cip-msa-v1-prd.au.cloudhub.io/api"

    def initialize usr, pwd
        @auth = Base64.encode64("#{usr}:#{pwd}").strip
        uri = URI.parse(BASE_URL)
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
    end

    def doGet path
        uri = URI.parse("#{BASE_URL}/#{path}")
        req = Net::HTTP::Get.new(uri.request_uri)
        req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36'
        req['X-Correlation-ID'] = SecureRandom.uuid
        req['X-Consumer-ID'] = AGENT
        req['X-Caller-ID'] = AGENT
        req['Authorization'] = "Basic #{@auth}"
        @http.request req
    end

    def get path
        JSON.parse(doGet(path).body)
    end
end