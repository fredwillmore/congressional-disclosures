require 'csv'

Disclosure.destroy_all if $options['destroy_all']

def get_text(url)
  pdf_path = 'file.pdf'
  open(pdf_path, 'wb') do |file|
    file << URI.open(pdf_url).read
  end
  images = MiniMagick::Image.read(File.open(pdf_path)).format("png", 0)
  image_path = 'page.png'
  images.write(image_path)
  image = RTesseract.new(image_path)
  puts image.to_s # Extracted text
end

def get_state_district_year(row)
  match = row["StateDst"].match(/([A-Z]+)(\d+)/)

  state = State.find_by(abbreviation: match[1])
  district = match[2].to_i
  year = row['Year']

  [state, district, year]
rescue
  debugger
end

directory_path = 'db/seeds/data/'
text_files = Dir.glob(File.join(directory_path, '*.txt'))

# Iterate over each text file
text_files.each do |file_path|
  # Read the file and parse it as a tab-separated file
  data = CSV.read(file_path, headers: true, col_sep: "\t", quote_char: '"', liberal_parsing: true)
  
  data.each do |row|
    filing_type = FilingType.find_by(abbreviation: row['FilingType'])
    
    next if row['StateDst'].nil?
    next unless row["StateDst"].match(/([A-Z]+)(\d+)/)
    
    first_name = row['First'].titleize.split.first
    last_name = row['Last'].titleize
    match = row["StateDst"].match(/([A-Z]+)(\d+)/)
    state = State.find_by(abbreviation: match[1])
    district = match[2].to_i
    year = row['Year']
    filing_date = row['FilingDate'].nil? ? nil : Date.strptime(row['FilingDate'], "%m/%d/%Y") 
      
    document_id = row['DocID']

    # obvisouly this will need to be a more robust solution
    last_name = case last_name
    when "Degette"
      "De Gette"
    when "Delauro"
      "De Lauro"
    when "Mccarthy"
      ["Mccarthy", "Mc Carthy"]
    when "Mccaul"
      ["Mccaul", "Mc Caul"]
    when "Mc Collum", "Mccollum"
      ["Mc Collum", "Mccollum"]
    when "Mccotter"
      "Mc Cotter"
    when "Mc Govern", "Mcgovern"
      ["Mc Govern", "Mcgovern"]
    when "Mchenry"
      "Mc Henry"
    when "Gonzalez", "Gonzalez Colon"
      ["Gonzalez", "González Colón"]
    else
      last_name
    end

    # obvisouly this will need to be a more robust solution
    name_options = case first_name
    when "Raul", "Raúl"
      ["Raul", "Raúl"]
    when "Bob", "Robert"
      ["Bob", "Robert"]
    when "Mike", "Michael"
      ["Mike", "Michael"]
    when "Bill", "William"
      ["Bill", "William"]
    when "James", "Jim"
      ["James", "Jim"]
    when "André", "Andre"
      ["André", "Andre"]
    when "Steve", "Stephen"
      ["Steve", "Stephen"]
    when "Denny", "Dennis"
      ["Denny", "Dennis"]
    when "Christopher", "Chris"
      ["Christopher", "Chris"]
    when "Elizabeth", "Liz"
      ["Elizabeth", "Liz"]
    when "Rebecca", "Becca"
      ["Rebecca", "Becca"]
    else
      [first_name]
    end

    legislators = Legislator.where(
      last_name: last_name
    ).where(
      name_options.map { |pattern| "first_name LIKE ?" }.join(" OR "),
      *name_options.map { |pattern| "#{pattern}%" }
    )

    if legislators.count > 1
      legislators = legislators.filter do |legislator|
        legislator.terms.by_state_district_year(state, district, year).any?
      end
    end

    if legislators.count != 1
      # just search by term
      terms = Term.by_state_district_year(state, district, year)
      legislators = Legislator.where(terms: terms.order(start_year: :desc).first)
    end

    # candidate records
    next unless row['Prefix'].in? ["HONORABLE", "Hon."]

    debugger if legislators.count != 1

    params = {
      legislator: legislators.first,
      filing_type: filing_type,
      state: state,
      district: district,
      year: year,
      filing_date: filing_date,
      document: Document.create(
        external_id: document_id
      )
    }


    Disclosure.create(params)
  rescue StandardError => e
    puts "oh no! an error occurred: #{e}"
    debugger
  end
  # Map to an array of file name and row count (data count excluding headers)
  { file_name: File.basename(file_path), row_count: data.size }
end
