class StreamController < ApplicationController
  include ActionController::Live

  MSGS = SizedQueue.new(15)

  heartbeat = Thread.new do
    loop do
      MSGS.push({ "type" => "heartbeat", "when" => Time.now })
      sleep 1
    end
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    sse = SSE.new(response.stream, event: "status")
    MSGS.clear
    while msg = MSGS.shift
      sse.write(JSON.dump(msg))
    end
  rescue ActionController::Live::ClientDisconnected
  end
end
