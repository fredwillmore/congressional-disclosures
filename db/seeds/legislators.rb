require 'faraday'
require 'faraday/retry'

Legislator.destroy_all if $options['destroy_all']

# directory_path = 'db/data/congress_members'

# # Get all text files in the directory
# files = Dir.glob(File.join(directory_path, '*.json'))

# data = []
# files.each do |file_path|
#   # Read the file and parse it as a tab-separated file
#   # file = File.open(file_path)
#   data.concat JSON.load(File.open(file_path))['members']
# end

http_connection = Faraday.new(url: "https://api.congress.gov/") do |faraday|
  faraday.request :retry, max: 5, interval: 5.0
  faraday.adapter Faraday.default_adapter
end


url = "https://api.congress.gov/v3/member"

loop do 
  puts "getting #{url}"

  # url_with_key = "#{url}&api_key=#{ENV.fetch('CONGRESS_GOV_API_KEY')}"
  uri = URI.parse(url)
  query_params = URI.decode_www_form(uri.query || '').to_h

  # debugger
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
  # debugger
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

    # debugger if !member['bioguideId']
    params = {
      bioguide_id: member['bioguideId'],
      prefix: member['honorificName'],
      first_name: member['firstName'],
      last_name: member['lastName'],
      birth_year: member['birthYear'].to_i,
    } rescue debugger
    
    # legislator = Legislator.find_or_initialize_by(params)
    legislator = Legislator.find_or_create_by(params)

    puts "legislator created successfully: #{legislator}"
  end

  url = body['pagination']['next']
  break unless url
end 
