Term.destroy_all if $options['destroy_all']

Legislator.all.each do |legislator|
  
  directory_path = 'db/seeds/data/member'
  file_name = "member_#{legislator.bioguide_id}.json"
  file_path = File.join(directory_path, file_name)
  
  if File.exist?(file_path)
    JSON.parse(File.read(file_path))['member']['terms'].each do |term_item|
      params = {
        legislator: legislator,
        chamber: term_item['chamber'],
        congress: term_item['congress'],
        state: State.find_by(abbreviation: term_item['stateCode']),
        district: term_item['district'],
        start_year: term_item['startYear'],
        end_year: term_item['endYear'],
        member_type: term_item['memberType'],
      }
      term = Term.find_or_create_by(params)
      
      puts "created term: #{term}"
    rescue Exception => e
      debugger
    end
  else
    puts "#{file_name} doesn't exist in #{directory_path}"
  end
  file
end
