FilingType.destroy_all if $options['destroy_all']

directory_path = 'db/seeds/data/'
file_name = "filing_types.json"
file_path = File.join(directory_path, file_name)
json = File.read(file_path)
values = JSON.load(json)

values.each do |abbreviation, name|

  FilingType.find_or_create_by(
    abbreviation: abbreviation,
    name: name
  )

end