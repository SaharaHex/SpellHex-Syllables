require 'rspec'
require 'sqlite3'
require_relative '../spellhex_dictionary' # Load the syllables dictionary class

RSpec.describe SpellHexDictionary do
  before(:all) do
    # Setup an in-memory temporary database for testing
    @db = SQLite3::Database.new(':memory:')
    @db.execute <<-SQL
      CREATE TABLE Dictionary (
        word TEXT,
        description TEXT,
        startLetter TEXT,
        vowel INTEGER,
        syllables INTEGER,
        category INTEGER
      );
    SQL

    # Insert test data into the dictionary
    @db.execute("INSERT INTO Dictionary (word, description, startLetter, vowel, syllables, category) 
                 VALUES ('apple', 'A fruit', 'A', 1, 2, 1)")
    @db.execute("INSERT INTO Dictionary (word, description, startLetter, vowel, syllables, category) 
                 VALUES ('art', 'A form of expression', 'A', 1, 1, 5)")
    @db.execute("INSERT INTO Dictionary (word, description, startLetter, vowel, syllables, category) 
                 VALUES ('arrow', 'A tool', 'A', 1, 2, 1)")
  end

  before(:each) do
    # Set up the restricted words list
    $restricted_words = ['arrow']
    # Mock the database connection and allow controlled behavior
    allow(SQLite3::Database).to receive(:new).and_return(@db)
  end

  after(:all) do
    # Close the database connection after all tests are complete
    @db.close unless @db.closed?
  end

  it 'fetches results while skipping restricted words and displaying appropriate messages' do
    # Test fetching results and ensuring restricted words are skipped
    expect {
      SpellHexDictionary.query_dictionary('A', 1, 2, 1)
    }.to output("  1. apple, A fruit\n\e[0;33;49m  A restricted word found.\e[0m\n").to_stdout    
  end

  it 'gracefully handles database connection errors' do
    # Simulate a connection error during database initialization
    allow(SQLite3::Database).to receive(:new).and_raise(SQLite3::Exception.new('Connection error'))

    expect {
      SpellHexDictionary.query_dictionary('A', 1, 2, 1)
    }.to output(/Error: Failed to connect to the database/).to_stdout
  end

  it 'gracefully handles query execution errors' do
    # Simulate a query execution error
    allow_any_instance_of(SQLite3::Database).to receive(:execute).and_raise(SQLite3::Exception.new('Query error'))

    expect {
      SpellHexDictionary.query_dictionary('A', 1, 2, 1)
    }.to output(/Error: Failed to execute query/).to_stdout
  end
end