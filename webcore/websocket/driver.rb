require_relative 'socket.rb'

module Webcore
module Websocket
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
            @listeners[type]&.each do |l|
                begin
                    l.call(type, action, data, socket)
                rescue => e
                    puts "[WSOCK] Websocket Listener Threw Exception: #{e}"
                    puts e.backtrace.map { |x| "[WSOCK]!\t #{x}" }
                end
            end
        end
    end
end
end