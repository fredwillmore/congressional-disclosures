PartyAffiliation.destroy_all if $options['destroy_all']

Legislator.all.each do |legislator|
  
  directory_path = 'db/seeds/data/member'
  file_name = "member_#{legislator.bioguide_id}.json"
  file_path = File.join(directory_path, file_name)
  
  if File.exist?(file_path)
    JSON.parse(File.read(file_path))['member']['partyHistory'].each do |history_item|
      params = {
        legislator: legislator,
        party: Party.find_by(abbreviation: history_item['partyAbbreviation']),
        start_year: history_item['startYear'],
        end_year: history_item['endYear']
      }
      party_affiliation = PartyAffiliation.find_or_create_by(params)
      
      puts "created party affiliation: #{party_affiliation}"
    rescue
      debugger
    end
  else
    puts "#{file_name} doesn't exist in #{directory_path}"
  end
  file
end
