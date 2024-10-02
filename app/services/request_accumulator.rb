class RequestAccumulator
  attr_accessor :requests
  attr_accessor :request_batch_file

  def initialize(request_batch_file = nil)
    @requests = []
    @request_batch_file = request_batch_file
  end

  def <<(request)
    requests << request
  end

end