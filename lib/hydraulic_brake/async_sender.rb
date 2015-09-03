module HydraulicBrake
  # In-memory, thread-safe storage for notices that haven't yet been sent to
  # Airbrake
  class AsyncSender
    attr_reader :sync_sender
    attr_reader :thread

    def initialize(opts={})
      @sync_sender = opts[:sync_sender]
      @q = Queue.new
      @capacity = opts[:capacity] || 100
      @logger = opts
      @thread = nil
    end

    def send_to_airbrake(notice)
      return will_not_deliver(notice) if @q.length >= @capacity

      @q.push(notice)

      return if @thread && @thread.alive?

      @thread = Thread.new do
        while n = @q.pop
          @sync_sender.send_to_airbrake(n)
        end
      end
    end

    private
    def will_not_deliver(notice)
      HydraulicBrake.logger.error(
        "[HydraulicBrake::AsyncSender has reached its capacity of "          \
        "#{@capacity} and the following notice will not be delivered "       \
        "Error: #{notice.error_class} - #{notice.error_message}\n"           \
        "Backtrace: \n#{notice.backtrace}")
    end
  end
end
