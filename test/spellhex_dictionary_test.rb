require 'minitest/autorun'
require 'mocha/minitest'  # Mocking library
require_relative '../spellhex_dictionary.rb'

class SpellHexDictionaryTest < Minitest::Test
  def setup
    @mock_db = mock('SQLite3::Database')
    SQLite3::Database.stubs(:new).returns(@mock_db)
    @mock_db.stubs(:close) # Allow the close method to be called
    $restricted_words = ["banned_word"]
  end

  def test_query_dictionary_returns_results
    # Mock query results
    @mock_db.stubs(:execute).returns([["example_word", "A sample description"]])

    results = SpellHexDictionary.query_dictionary("A", "E", "2", "1")

    # Capture console output for assertion
    output = capture_io { SpellHexDictionary.query_dictionary("A", "E", "2", "1") }.first
    clean_output = output.gsub(/\e\[[0-9;]*m/, '')  # Removes ANSI codes
    assert_match (/example_word, A sample description/), clean_output
    puts "✅ Test Passed: query dictionary successfully returned expected results" # Confirmation feedback
  end

  def test_restricted_word_detection
    # Mock query results with a restricted word
    @mock_db.stubs(:execute).returns([["banned_word", "A sample description"]])

    output = capture_io { SpellHexDictionary.query_dictionary("A", "E", "2", "1") }.first
    clean_output = output.gsub(/\e\[[0-9;]*m/, '')  # Remove ANSI color codes
    assert_match (/A restricted word found./), clean_output
    puts "✅ Test Passed: restricted word detection" # Confirmation feedback
  end

  def test_query_dictionary_handles_empty_results
    @mock_db.stubs(:execute).returns([])

    output = capture_io { SpellHexDictionary.query_dictionary("X", "O", "3", "2") }.first
    assert_match (/No matching records found./), output
    puts "✅ Test Passed: handles empty results" # Confirmation feedback
  end

  def test_get_all_vowels
    @mock_db.stubs(:execute).returns([[1, "A", "Short vowel"], [2, "E", "Medium vowel"]])

    vowels = SpellHexDictionary.get_all_vowels
    assert_equal 2, vowels.size
    assert_equal "A", vowels.first[:name]
    puts "✅ Test Passed: get all vowels" # Confirmation feedback
  end

  def test_get_all_categories
    @mock_db.stubs(:execute).returns([[1, "Animals", "Living beings"], [2, "Objects", "Non-living things"]])

    categories = SpellHexDictionary.get_all_categories
    assert_equal 2, categories.size
    assert_equal "Animals", categories.first[:name]
    puts "✅ Test Passed: get all categories" # Confirmation feedback
  end

  def test_get_word_vowel
    @mock_db.stubs(:execute).returns([["Lion", "O", "Long vowel", "2", "Animals"]])

    output = capture_io { SpellHexDictionary.get_word_vowel("Lion") }.first
    assert_match (/Vowel: O - Long vowel, Syllables: 2, Category: Animals/), output
    puts "✅ Test Passed: get word vowel" # Confirmation feedback
  end
end
