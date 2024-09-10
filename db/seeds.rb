
require 'csv'

Rake::Task['db:seed:parties'].invoke
Rake::Task['db:seed:states'].invoke
Rake::Task['db:seed:filing_types'].invoke
Rake::Task['db:seed:legislators'].invoke
Rake::Task['db:seed:party_affiliations'].invoke
Rake::Task['db:seed:terms'].invoke
Rake::Task['db:seed:disclosures'].invoke
