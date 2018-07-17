require 'json'

module Webcore
module Websocket
    class Socket
        # Extra data the driver may want to use
        attr_accessor :data
        attr_reader :ws
        attr_reader :request

        def initialize ws, request, driver
            @ws = ws
            @connected = false
            @request = request
            @driver = driver
            @types = []
            @data  = {}
            @onConnTmp = []

            @ws.onopen { on_open }
            @ws.onmessage { |msg| on_msg msg }
            @ws.onclose { on_close }
        end

        def on_open
            @connected = true
            @onConnTmp.each { |x| x.call() }
            @onConnTmp.clear
        end

        def on_msg msg
            begin
                json = JSON.parse(msg)
                if json['type'] == 'types' && json['action'] == 'identify'
                    @types << json['data'].to_sym
                else
                    @driver.on_msg(json['type'].to_sym, json['action'].to_sym, json['data'], self)
                end
            rescue => e
                puts "[WSOCK] Websocket Listener Threw Exception: #{e}"
                puts e.backtrace.map { |x| "[WSOCK]!\t #{x}" }
            end
        end

        def on_close
            @connected = false
            @request = nil
        end

        def send type, action, data
            pr = Proc.new { @ws.send JSON.generate( { type: type, action: action, data: data } ) }
            if connected?
                pr.call()
            else
                @onConnTmp << pr
            end
        end

        def connected?
            @connected
        end

        def knows? type
            @types.include?(type.to_sym)
        end
    end
end
end