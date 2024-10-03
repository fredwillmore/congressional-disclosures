require 'faraday'
require 'faraday/retry'

Congress.destroy_all if $options['destroy_all']

http_connection = Faraday.new(url: "https://api.congress.gov/") do |faraday|
  faraday.request :retry, max: 5, interval: 5.0
  faraday.adapter Faraday.default_adapter
end

url = "https://api.congress.gov/v3/congress"
endpoint = url.remove('https://api.congress.gov')

loop do 
  # sleep(1.0)

  puts "getting #{url}"

  uri = URI.parse(url)
  query_params = URI.decode_www_form(uri.query || '').to_h

  file = http_connection.get(
    endpoint,
    {
      offset: query_params['offset'],
      limit: query_params['limit'],
      format: :json,
      api_key: ENV.fetch('CONGRESS_GOV_API_KEY')
    }
  )
  body = JSON.load(file.body)

  body['congresses'].each do |congress_info|
    
    params = {
      name: congress_info["name"],
      start_year: congress_info["startYear"],
      end_year: congress_info["endYear"],
      sessions: congress_info["sessions"],
    }
    
    congress = Congress.find_or_create_by(params)
    
    puts "congress created successfully: #{congress}"
  rescue e
    debugger
  end

  url = body['pagination']['next']
  break unless url
end 

congresses = Congress.all.order(:start_date).map.with_index do |congress, i|
  [i+1, congress]
end.to_h

Term.all.each do |term|
  congress = Congress
    .where(start_year: term.start_year)
    .or(Congress.where(end_year: term.start_year))
    .or(Congress.where(start_year: term.end_year))
    .or(Congress.where(end_year: term.end_year))
    .first
  term.update(congress_id: congress.id)
rescue Exception => e
  debugger
end