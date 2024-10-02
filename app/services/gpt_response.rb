class GptResponse
  attr_accessor :response_body, :page, :response_type, :document_id

  def initialize(response: )
    if response.respond_to?(:body)
      @response_body = JSON.parse(response.body)
    else
      response_json = JSON.parse(response)
      @response_body = response_json['response']['body']
      custom_id_components = response_json["custom_id"].split('-')
      @page = custom_id_components.pop
      @response_type = custom_id_components.pop
      @document_id = custom_id_components.pop
    end
  rescue StandardError => e
    debugger
  end
  
  def get_json_response
    structured_json = response_body["choices"][0]["message"]["content"]
    if structured_json.match(/```(?:json)\n(.*)\n```/m)
      structured_json = structured_json.match(/```(?:json)\n(.*)\n```/m)[1]
    end

    JSON::parse(structured_json)
  rescue StandardError => e
    debugger
  end

end
