require 'xmpp4r/client'
require 'thread'
require 'active_support/json'
require 'active_support/core_ext/hash'

class StellaGcmXmpp
  def initialize(id, password, debug = false, log = false)
    @id = id
    @password = password
    @log = log
    @limit = 100
    @semaphore = Mutex.new
    Jabber::debug = debug
  end
  def connect
    jid = Jabber::JID::new(@id)

    @client = Jabber::Client::new(jid)
    @client.use_ssl = true
    @client.connect("gcm.googleapis.com", 5235)
    @client.auth(@password)
  end
  def callback(function = nil)
    @client.add_message_callback do |m|
      @semaphore.synchronize do
        @limit += 1
      end
      begin
        result = Hash.from_xml(m.to_s).with_indifferent_access
      rescue
        return self.fail
      end
      begin
        data = JSON.parse(result[:message][:gcm]).with_indifferent_access
      rescue
        return self.fail
      end
      if data[:message_type] == 'ack'
        print "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] GCM send Success id: #{data[:message_id]}, limit: #{@limit}\n" if @log
      else
        print "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] GCM send Failed id: #{data[:message_id]} error: #{data[:error]}\n" if @log
      end
      call(function) unless function.nil?
    end
  end
  def fail
    print "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] GCM send Critical Error\n" if @log
  end
  def send(to, message_id, data)
    json = {:to => to,
            :message_id => message_id,
            :data => data,
            :time_to_live => 600,
            :delay_while_idle => false}
    msg = "<message id=\"\">
             <gcm xmlns=\"google:mobile:data\">
               #{json.to_json}
             </gcm>
            </message>"
    if @limit < 1
      print "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] ait...GCM limit"
      sleep 1
      return self.send(to, message_id, data)
    end
    @client.send msg
    @semaphore.synchronize do
      @limit -= 1
    end
  end
  def disconnect
    @client.close
    @client = nil
  end
  def reconnect
    self.reconnect
    self.connect
  end
  def stable_blank
    self.send("NULL", "BLANK_STABLE_PACKET", {:type => nil})
  end
end