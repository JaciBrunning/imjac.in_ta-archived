require 'json'

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
            json = JSON.parse(msg)
            if json['type'] == 'types' && json['action'] == 'identify'
                @types << json['data'].to_sym
            else
                @driver.on_msg(json['type'].to_sym, json['action'].to_sym, json['data'], self)
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

    class Driver
        attr_accessor :data

        def initialize
            @sockets = []
            @listeners = {}
            @data = {}
        end

        def handle ws, request
            s = Socket.new(ws, request, self)
            @sockets << s
            s
        end

        def dispatch type, action, data, &block
            EM.next_tick do
                @sockets.select! do |sock|
                    if sock.connected? && sock.knows?(type)
                        tosend = true
                        tosend = block.call(sock) unless block.nil?

                        sock.send(type, action, data) if tosend
                    end
                    sock.connected?
                end
            end
        end

        def listen type, &block
            @listeners[type] ||= []
            @listeners[type] << block
        end

        # To be called by websocket
        def on_msg type, action, data, socket
            @listeners[type]&.each { |l| l.call(type, action, data, socket) }
        end
    end
end