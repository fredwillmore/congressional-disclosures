State.destroy_all if $options['destroy_all'] == 'true'

directory_path = 'db/seeds/data/'
file_name = "states.json"
file_path = File.join(directory_path, file_name)
json = File.read(file_path)
values = JSON.load(json)

values.each do |abbreviation, name|

  State.find_or_create_by(
    abbreviation: abbreviation,
    name: name
  )

end