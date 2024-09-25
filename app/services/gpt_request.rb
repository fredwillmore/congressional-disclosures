class GptRequest
  attr_accessor :request_type, :content

  def initialize(request_type: , content:)
    @request_type = request_type
    @content = content
  end

  def prompt
    case request_type
    when :transaction
      transactions_prompt
    when :asset
      assets_prompt
    end
  end

  def endpoint
    "https://api.openai.com/v1/chat/completions"
  end

  def api_key
    ENV.fetch('OPENAI_API_KEY')
  end

  def headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
  end

  def get_json_response
    response = send
    structured_json = JSON.parse(response.body)["choices"][0]["message"]["content"]
    if structured_json.match(/```(?:json)\n(.*)\n```/m)
      json = structured_json.match(/```(?:json)\n(.*)\n```/m)[1]
    else
      json = structured_json
    end
    JSON::parse(json)
  end

  def send
    HTTP.headers(headers).post(endpoint, body: payload)
  end

  def gpt_model
    "gpt-4o-mini"
  end

  def max_tokens
    14000
  end

  def pages
    case request_type
    when :transaction
      transactions_pages
    when :asset
      assets_pages
    end
  end

  def assets_pages
    10
  end

  def transactions_pages
    10
  end

  def payload
    {
      model: gpt_model, # or "gpt-3.5-turbo"
      # model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a helpful assistant. Your task is to process text and return a valid json object." },
        { role: "user", content: prompt }
      ],
      max_tokens: max_tokens
    }.to_json
  end

  def assets_prompt
    %Q(
Input: You are given a text that contains multiple assets, with each asset's data possibly spanning multiple lines.
Asset definitions may include blank lines.
Asset definitions are separated by a blank line.
Spaces are used to align data in different columns. Each asset contains the following fields:
  Asset name (first line and all subsequent lines until a blank line)
  Owner ("SP", "DC", "JT", or "")
  Value of asset (range)
  Income type(s) (comma-separated list)
  Income (range)

Value of asset must match one of the following:
  'None',
  '$1,001 - $15,000',
  '$15,001 - $50,000',
  '$50,001 - $100,000',
  '$100,001 - $250,000',
  '$250,001 - $500,000',
  '$500,001 - $1,000,000',
  "$1,000,001 - $5,000,000",
  "Spouse/DC Over $1,000,000"

Income type(s) will be a comma-separated list of values. Each value in the list must match the following:
  "None",
  "Bond Interest",
  "Book Royalty",
  "Capital Gains",
  "Dividends",
  "Interest",
  "Partnership Income",
  "Pension",
  "Rent",
  "Royalties",
  "S-Corp Income",
  "Spouse Salary",
  "Tax-Deferred"

Income must match one of the following:
  "None",
  "$1 - $200",
  "$201 - $1,000",
  "$1,001 - $2,500",
  "$2,501 - $5,000",
  "$5,001 - $15,000",
  '$15,001 - $50,000',
  "$50,001 - $100,000",
  "$100,001 - $1,000,000",
  "$1,000,001 - $5,000,000",
  "Spouse/DC Over $1,000,000"

Your task is to output an array of arrays. Each inner array should contain the following information in order:
  Asset name
  Owner
  Value of asset
  Income type(s)
  Income range

Example text: 
```
Isabella MacArthur ⇒                   DC    $50,001 -    Dividends     $201 -     d
Guggenheim S&P 500 Equal Weight ETF (RSP)    $100,000                   $1,000

MacArthur Family 2008 Irr Tr FBO David DCcArt$1,001 - $15,Dividends     None       b
Accenture plc Class A Ordinary Shares (ACN)

MacArthur Family 2008 Irr Tr FBO David DCcArtNone⇒        Capital Gains,$1 - $200  b
AMER TOWER CORP B/E 04.500% 011518                         Interest

DESCRIP: Corp bond
```

Desired Output:
[
  [
    "Isabella MacArthur ⇒ Guggenheim S&P 500 Equal Weight ETF (RSP)",
    "DC",
    "$50,001 - $100,000",
    "Dividends",
    "$201 - $1,000"
  ],
  [
    "MacArthur Family 2008 Irr Tr FBO David Accenture plc Class A Ordinary Shares (ACN)",
    "DC",
    "$1,001 - $15,000",
    "Dividends",
    "None"
  ],
  [
    "MacArthur Family 2008 Irr Tr FBO David AMER TOWER CORP B/E 04.500% 011518 AMER TOWER CORP B/E 04.500% 011518 DESCRIP: Corp bond",
    "DC",
    "None",
    "Capital Gains, Interest",
    "$1 - $200"
  ]
]

The output array values should not include any newlines. Concatenate text with spaces.
The output array values should be enclosed in quotes.
Ignore the single character values at the end of some lines.
Please process the following text in the same way.
Please return a complete JSON array of all table entries, without omitting any entries or adding comments.

#{content}
    )
  end

  def transactions_prompt
    %Q(
Input: You are given a text that contains multiple transaction definitions.
Transaction definitions may span multiple lines.
Transaction definitions may include blank lines.
Transaction definitions are separated by two blank lines.
Spaces are used to align data in different columns. Each transaction contains the following fields:
  Asset name (first line and all subsequent lines until a blank line)
  Owner ("SP", "DC", "JT", or "")
  Date (date)
  Transaction Type ("P", "S", or "S (partial)")
  Amount (range)

the "Amount" field must be one of the following:
  'None',
  '$1 - $200',
  '$201 - $1,000',
  '$1,001 - $15,000',
  '$15,001 - $50,000',
  '$50,001 - $100,000',
  '$100,001 - $250,000',
  '$250,001 - $500,000',
  '$500,001 - $1,000,000',
  '$1,000,001 - $5,000,000',
  '$5,000,001 - $25,000,000',
  '$25,000,001 - $50,000,000',
  '$50,000,001 - $100,000,000'

Your task is to output an array of arrays. Each inner array should contain the following information in order:
  Asset name
  Owner
  Date
  Transaction Type
  Amount

Example text: 
```
LOOMIS SAYLES SM CAP VAL INST (IRA)                SP      12/23/2013      P      $1,001 - $15,000


PIMCO EMERGING MKTS BOND A (IRA)                   SP      03/13/2013      S      $15,001 - $50,000   e
                                                                        (partial)


MacArthur Family 2008 Irr Tr FBO David MacArthur ⇒ DC      08/7/2015       P       $1,001 - $15,000
SINCLAIR TELEVISION 06.375% 110121

DESCRIPTI: corporate bond


Vanguard-JM Chu Irrevocable Trust II ⇒ Vanguard-JM        02/5/2019       S       $50,001 -            c
Chu Irrevocable Trust II-managed ⇒                                        (partial) $100,000
Vanguard Total Intl Stock Index admiral Cl (VTIaX) [MF]
```

Desired Output:
[
  [
    'LOOMIS SAYLES SM CAP VAL INST (IRA)',
    'SP',
    '12/23/2013',
    'P',
    '$1,001 - $15,000'
  ],
  [
    'PIMCO EMERGING MKTS BOND A (IRA)',
    'SP',
    '03/13/2013',
    'S (partial)',
    '$15,001 - $50,000'
  ],
  [
    'MacArthur Family 2008 Irr Tr FBO David MacArthur ⇒ SINCLAIR TELEVISION 06.375% 110121 DESCRIPTI: corporate bond',
    'DC',
    '08/07/2015',
    'P',
    '$1,001 - $15,000'
  ],
  [
    'Vanguard-JM Chu Irrevocable Trust II ⇒ Vanguard-JM Chu Irrevocable Trust II-managed ⇒ Vanguard Total Intl Stock Index admiral Cl (VTIaX) [MF]',
    '',
    '02/5/2019',
    'S (partial)',
    '$50,001 - $100,000'
  ]
]

The output array values should not include any newlines. Concatenate text with spaces.
The output array values should be enclosed in quotes.
Ignore the single character values at the end of some lines.
Please process the following text in the same way
Please return a complete JSON array of all table entries, without omitting any entries or adding comments.

#{content}
    )
  end

  def filer_information_prompt
    case abbreviation
    when 'A'
      %Q(
        )
    when 'O'
      %Q(
        Please convert the following text into a JSON hash.
        The text contains the following values:
          Name (string),
          Status (string),
          State/District (state code and 1-2 digit number),
          Filing Type (string),
          Filing Year (year),
          Filing Date (date)

        Please return a JSON hash
        Hash keys are "name", "status", "state_district", "filing_type", "filing_year", "filing_date"
        Hash values are values of Name, Status, State/District, Filing Type, Filing Year, Filing Date


        Example text:
        ```
F I

Name:                 Hon. Thomas MacArthur
Status:               Member

State/District:       NJ03



F I

Filing Type:          Annual Report
Filing Year:          2015

Filing Date:          05/14/2016
        ```

        Desired output:
        ```
          {
            "filer_information" => {
              "name"=>"Hon. Thomas MacArthur",
              "status"=>"Member",
              "state_district"=>"NJ03"
            },
            "filing_information" => {
              "filing_type"=>"Annual Report",
              "filing_year"=>2015,
              "filing_date"=>"05/14/2016"
            },
          }
        ```

        Please process the following text in the same way:
      )
    else
    end
  end

end