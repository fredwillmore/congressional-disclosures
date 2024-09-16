class FilingType < ApplicationRecord
  scope :with_text_documents, -> { original_fd }
  scope :original_fd, -> { where(abbreviation: ["O"]) }

  def document_directory
    abbreviation == 'P' ? "ptr-pdfs" : "financial-pdfs"
  end

  def assets_prompt
    %Q(
Input: You are given a text that contains multiple assets, with each asset's data possibly spanning multiple lines.
Asset definitions may include blank lines.
Asset definitions are separated by a blank line.
Spaces are used to align data in different columns. Each asset contains the following fields:
  Asset name (first line and all subsequent lines until a blank line)
  Owner (short code)
  Value of asset (range)
  Income type(s)
  Income (range)

the "Value of asset" field must be one of the following:
  'None',
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
    "$201 - $1,000",
  ],
  [
    "MacArthur Family 2008 Irr Tr FBO David Accenture plc Class A Ordinary Shares (ACN)",
    "DC",
    "$1,001 - $15,000",
    "Dividends",
    "None",
  ],
  [
    "MacArthur Family 2008 Irr Tr FBO David AMER TOWER CORP B/E 04.500% 011518 AMER TOWER CORP B/E 04.500% 011518 DESCRIP: Corp bond",
    "DC",
    "None",
    "Capital Gains, Interest",
    "$1 - $200",
  ]
]

The output values should not include any newlines. Concatenate text with spaces.
Please process the following text in the same way
Please return a complete JSON array of all table entries, without omitting any entries or adding comments.  
    )
  end

  def transactions_prompt
    %Q(
Input: You are given a text that contains multiple transactions.
Transaction definitions may span multiple lines.
Transaction definitions may include blank lines.
Transaction definitions are separated by two blank lines.
Spaces are used to align data in different columns. Each transaction contains the following fields:
  Asset name (first line and all subsequent lines until a blank line)
  Owner (short code)
  Date (date)
  Transaction Type (P, S, or S (partial))
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
    P',
    '$1,001 - $15,000'
  ]
]

The output values should not include any newlines. Concatenate text with spaces.
Please process the following text in the same way
Please return a complete JSON array of all table entries, without omitting any entries or adding comments.
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
