require 'faraday'
require 'faraday/retry'

Legislator.destroy_all if $options['destroy_all']

http_connection = Faraday.new(url: "https://api.congress.gov/") do |faraday|
  faraday.request :retry, max: 5, interval: 5.0
  faraday.adapter Faraday.default_adapter
end

url = "https://api.congress.gov/v3/member"

loop do 
  puts "getting #{url}"

  uri = URI.parse(url)
  query_params = URI.decode_www_form(uri.query || '').to_h

  endpoint = url.remove('https://api.congress.gov')
  sleep(1.0)
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

  body['members'].each do |member|
    download_new = $options['download_new']
    
    directory_path = 'db/seeds/data/member'
    file_name = "member_#{member['bioguideId']}.json"
    file_path = File.join(directory_path, file_name)
    
    if download_new || !File.exist?(file_path)
      sleep(1.0)
      member_file = http_connection.get(member['url'], { format: :json, api_key: ENV.fetch('CONGRESS_GOV_API_KEY')})
      File.open(file_path, 'w') do |file|
        file.puts member_file.body
      end
      puts "#{file_name} created successfully in #{directory_path}"
      # puts member_file
    else
      puts "#{file_name} already exists in #{directory_path}"
    end

    # now do the rest of the work
    member = JSON.parse(File.read(file_path))['member']

    params = {
      bioguide_id: member['bioguideId'],
      prefix: member['honorificName']&.titleize,
      first_name: member['firstName']&.titleize,
      last_name: member['lastName']&.titleize,
      birth_year: member['birthYear'].to_i,
    }
    
    legislator = Legislator.find_or_create_by(params)
    
    puts "legislator created successfully: #{legislator}"
  rescue e
    debugger
  end

  url = body['pagination']['next']
  break unless url
end 
