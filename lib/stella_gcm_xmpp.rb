require 'xmpp4r/client'
require 'active_support/json'
require 'active_support/core_ext/hash'

class StellaGcmXmpp
  def initialize(id, password, debug = false)
    @id = id
    @password = password
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
      begin
        result = Hash.from_xml(m.to_s).with_indifferent_access
      rescue
        return
      end
      begin
        data = JSON.parse(result[:message][:gcm]).with_indifferent_access
      rescue
        return self.fail
      end
      if data[:message_type] == 'ack'
        print "GCM send Success id: #{data[:message_id]}\n"
      else
        print "GCM send Failed id: #{data[:message_id]} error: #{data[:error]}\n"
      end
      call(function) unless function.nil?
    end
  end
  def fail
    print "GCM send Critical Error\n"
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
    @client.send msg
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