# SpellHexDictionary class connecting to Syllables Dictionary and returning results 
class SpellHexDictionary
  require 'colorize' # for text coloring
  require 'sqlite3' # for databse

  def self.query_dictionary(start_letter, vowel_id, syllables_count, category_id)    
    begin
      # Connect to the database
      db = SQLite3::Database.new 'spellhex_db.sqlite3'
    rescue SQLite3::Exception => e
      puts "Error: Failed to connect to the database - #{e.message}".red
      return
    end
  
    begin
      # Ensure all inputs are strings and sanitized
      start_letter = start_letter.to_s
      vowel_id = vowel_id.to_s
      category_id = category_id.to_s

      # Determine the appropriate SQL condition for the category
      category_condition = category_id == "0" ? "d.category > ?" : "d.category = ?"

      # Prepare the SQL query
      sql = if syllables_count == "4+"
              <<-SQL
                SELECT d.word, d.description
                FROM Dictionary d
                WHERE d.startLetter = ?
                  AND d.vowel = ?
                  AND d.syllables >= 4
                  AND #{category_condition}
              SQL
            else
              <<-SQL
                SELECT d.word, d.description
                FROM Dictionary d
                WHERE d.startLetter = ?
                  AND d.vowel = ?
                  AND d.syllables = ?
                  AND #{category_condition}
              SQL
            end

      # Convert syllables_count to an integer if it's not "4+"
      syllables_count = syllables_count.to_i unless syllables_count == "4+"

      # Execute the query with the appropriate parameters
      params = [start_letter, vowel_id]
      params << (syllables_count == "4+" ? nil : syllables_count) unless syllables_count == "4+"
      params << category_id
      results = db.execute(sql, params.compact)
    
      # Check if any results were returned
      if results.empty?
        puts "Sorry this is a limited Dictionary, No matching records found.".light_cyan
      else
        # Print the results
        results.each_with_index do |row, index|
          # Optional: Skip restricted words
          if $restricted_words.any? { |rw| row[0].downcase.include?(rw) }
            puts "  A restricted word found.".yellow
            next # Skip this definition          
          else
            puts "  #{index + 1}. #{row[0]}," + " #{row[1]}".light_white
          end  
        end
      end
    rescue SQLite3::Exception => e
      # Handle unexpected errors
      puts "Error: Failed to execute query - #{e.message}".yellow
    ensure
      # Close the database connection
      db.close if db
    end
  end

  def self.get_all_vowels
    begin
      # Connect to the database
      db = SQLite3::Database.new 'spellhex_db.sqlite3'
    rescue SQLite3::Exception => e
      puts "Error: Failed to connect to the database - #{e.message}".red
      return []
    end
  
    begin
      # Prepare the SQL query
      sql = <<-SQL
        SELECT Id, name, description
        FROM Vowels
      SQL
  
      # Execute the query
      results = db.execute(sql)
  
      # Extract the vowel names and descriptions and return as an array of hashes
      vowels = results.map { |row| { Id: row[0], name: row[1], description: row[2] } }
      return vowels
    rescue SQLite3::Exception => e
      # Handle unexpected errors
      puts "Error: Failed to execute query - #{e.message}".yellow
      return []
    ensure
      # Close the database connection
      db.close if db
    end
  end

  def self.get_all_categories
    begin
      # Connect to the database
      db = SQLite3::Database.new 'spellhex_db.sqlite3'
    rescue SQLite3::Exception => e
      puts "Error: Failed to connect to the database - #{e.message}".red
      return []
    end
  
    begin
      # Prepare the SQL query
      sql = <<-SQL
        SELECT Id, name, description
        FROM Category
      SQL
  
      # Execute the query
      results = db.execute(sql)
  
      # Extract the category names and descriptions and return as an array of hashes
      categories = results.map { |row| { Id: row[0], name: row[1], description: row[2] } }
      return categories
    rescue SQLite3::Exception => e
      # Handle unexpected errors
      puts "Error: Failed to execute query - #{e.message}".yellow
      return []
    ensure
      # Close the database connection
      db.close if db
    end
  end
  
  # Looking up Syllables Dictionary by word search only 
  def self.get_word_vowel(start_letter)
    begin
      # Connect to the database
      db = SQLite3::Database.new 'spellhex_db.sqlite3'
    rescue SQLite3::Exception => e
      puts "Error: Failed to connect to the database - #{e.message}".red
      return
    end
  
    begin
    # Prepare the SQL query with a join to include the vowel name
    sql = <<-SQL
      SELECT d.word, v.name AS vowel_name, v.description AS vowel_description, d.syllables, c.name AS category_name
      FROM Dictionary d
      JOIN Vowels v ON d.vowel = v.Id
      JOIN Category c ON d.category = c.Id
      WHERE d.word = ?
    SQL
  
      # Execute the query with the provided parameters
      results = db.execute(sql, [start_letter])
  
    # Check if any results were returned
    unless results.empty?
      # Print the results
      results.each do |row|
        puts "  Vowel: #{row[1].upcase} - #{row[2]}, Syllables: #{row[3]}, Category: #{row[4]}".light_cyan
      end
    end

    rescue SQLite3::Exception => e
      # Handle unexpected errors
      puts "Error: Failed to execute query - #{e.message}".yellow
    ensure
      # Close the database connection
      db.close if db
    end
  end

end