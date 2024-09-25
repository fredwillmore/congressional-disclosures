class RequestAccumulator
  attr_accessor :request_batch_file

  def initialize(request_batch_file = nil)
    @request_batch_file = request_batch_file
  end

  def puts(payload = nil)
    debugger
    # request_batch_file.puts payload
  end

end