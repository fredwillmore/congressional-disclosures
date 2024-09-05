
Party.destroy_all if $options['destroy_all'] == 'true'

{
  'I' => "Independent",
  "ID" => "Independent Democrat",
  'D' => "Democrat",
  'R' => "Republican",
  'L' => "Libertarian",
}.each do |abbreviation, name|

  Party.find_or_create_by(
    abbreviation: abbreviation,
    name: name
  )

end