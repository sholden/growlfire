require "growlfire/version"
require 'yajl'
require 'ruby-growl'
require 'net/http'
require 'net/https'
require 'em-http-request'
require 'logger'

module Growlfire
  class Client
    attr_reader :host, :token, :room_name

    def initialize(host, token, room_name, options = {})
      @host, @token, @room_name = host, token, room_name
      @growl = Growl.new(options.fetch(:host) { 'localhost' }, 'Growlfire')
      @growl.add_notification('growlfire', 'Growlfire', Growlfire.icon)
      @log = options.fetch(:log) { Logger.new(STDOUT) }
      @log.level = Growlfire.debug? ? Logger::DEBUG : Logger::FATAL
      @user_names = {}
    end

    def run
      parser = Yajl::Parser.new
      parser.on_parse_complete = Proc.new {|message| handle_message(message)}

      EventMachine.run do
        opts = {inactivity_timeout: 0, connection_timeout: 0, keepalive: true}
        http = EventMachine::HttpRequest.new(room_uri).get(opts)
        http.stream {|chunk| parser << chunk }
        http.errback { stop! }
      end
    end

    def handle_message(message)
      @log.debug "Stream: #{message.inspect}"
      if message['type'] == 'TextMessage'
        growl user_name(message['user_id']), message['body']
      end
    end

    def growl(title, body)
      @growl.notify 'growlfire', title, body
    end

    def stop!
      EventMachine.stop
      growl 'Growlfire stopped', 'Growlfire shutting down.'
      @log.fatal 'Growlfire stopped.'
      exit
    end

    def room_id
      @room_id ||= begin
        rooms = Yajl.load request room_list_uri
        @log.debug "Rooms: #{rooms.inspect}"
        room = rooms['rooms'].find{|r| r['name'] =~ /^#{room_name}$/i}
        raise 'Could not find room!' unless room
        room['id']
      end
    end

    def user_name(user_id)
      @user_names[user_id] ||= begin
        user = Yajl.load request user_uri user_id
        @log.debug "User: #{user.inspect}"
        user['user']['name']
      rescue
        user_id.to_s
      end
    end

    def user_uri(user_id)
      URI.parse("https://#{token}:x@#{host}.campfirenow.com/users/#{user_id}.json")
    end

    def room_uri
      URI.parse("https://#{token}:x@streaming.campfirenow.com/room/#{room_id}/live.json")
    end

    def room_list_uri
      URI.parse("https://#{token}:x@#{host}.campfirenow.com/rooms.json")
    end

    def request(uri)
     Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
       request = Net::HTTP::Get.new uri.request_uri
       request.basic_auth uri.user, uri.password
       response = http.request request
       response.body
     end
    end
  end

  def self.run(host, room)
    Client.new(host, token, room).run
  end

  def self.token
    ENV['CAMPFIRE_TOKEN'] || File.read(File.join(ENV['HOME'], '.campfire')).lines.first.strip
  rescue
    raise 'Token not found!'
  end

  def self.icon
    File.open(File.join(File.dirname(__FILE__), 'logo-cf.png'), 'rb').read
  end

  def self.debug?
    ENV['GROWLFIRE_DEBUG'] = 'true'
  end
end
