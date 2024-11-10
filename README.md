# Congressional Financial Disclosures Project

This project aims to provide an insightful analysis of Congressional financial disclosures in compliance with the STOCK Act, which mandates transparency in personal financial dealings by members of Congress. We utilize AI to extract and process information from publicly available PDF files of these disclosures, providing accessible and structured data for further analysis.

## What is the STOCK Act?

The **Stop Trading on Congressional Knowledge (STOCK) Act**, passed in 2012, requires members of Congress and their staff to publicly disclose their financial transactions. This law is intended to prevent insider trading and conflicts of interest, ensuring that those in public office do not use non-public information for personal financial gain.

### Project Overview

This project automates the extraction of key financial information from congressional disclosure PDFs using artificial intelligence (AI). We leverage cutting-edge techniques in **Natural Language Processing (NLP) and optical character recognition (OCR)** to read and parse these files, transforming unstructured data into a structured, searchable format.

#### Key Features

- **AI-powered extraction:** Automated extraction of financial transactions from PDF files using AI and machine learning models.
- **PDF Parsing:** AI models process and extract relevant details from complex, scanned, or poorly formatted PDF documents.
- **Data Structuring:** The extracted data is structured into formats (e.g., JSON, CSV) suitable for analysis and research.

### AI Models and Tools this Project is Using:

- Optical Character Recognition (OCR) to extract text from scanned PDF documents.
- Natural Language Processing (NLP) to identify and structure key information.
- Custom algorithms to ensure high accuracy in parsing complex or messy document layouts.

### Data Sources
Financial disclosures are sourced from publicly available records as required under the STOCK Act. These records are essential for holding public officials accountable and ensuring transparency in government operations.

version 1.0
results from processing disclosures - the fail rate is too high (particularly for transactions) for a production app but will be ok for demonstration:

processed 3375 disclosures
asset_success_count 97055
transaction_success_count 51271
asset_fail_count 82
transaction_fail_count 885

