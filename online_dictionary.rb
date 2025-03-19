# OnlineDictionary class connecting to Dictionary Api and returning results
class OnlineDictionary
  require 'net/http'
  require 'json'
  require 'colorize' # for text coloring

  # Class method to Load restricted words from a JSON file into a global variable
  def self.load_restricted_words(file_path)
    begin
      file = File.read(file_path)
      $restricted_words = JSON.parse(file) # Assign to a global variable
    rescue Errno::ENOENT
      puts "Error: Could not find the restricted words file at #{file_path}."
      $restricted_words = [] # Assign an empty array if the file is not found
    rescue JSON::ParserError
      puts "Error: Failed to parse the restricted words JSON file."
      $restricted_words = [] # Assign an empty array if JSON parsing fails
    end
  end

  # Function to search a word in the online dictionary
  def self.search_online_dictionary(word)
    if $restricted_words.include?(word.downcase)
      puts "  This word is restricted and cannot be searched.".yellow
      return
    end

    begin
    # API endpoint
    url = URI("https://api.dictionaryapi.dev/api/v2/entries/en/#{word}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == "https"
    
    request = Net::HTTP::Get.new(url)
    # request["Authorization"] = "Bearer YOUR_API_KEY" # Add headers if needed
    # request["Content-Type"] = "application/json"

    # Send the request
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      # Parse the JSON response
      data = JSON.parse(response.body)

      # Display filtered results
      meanings = data[0]["meanings"]
      meanings.each do |meaning|
        part_of_speech = meaning["partOfSpeech"]
        puts "#{part_of_speech.capitalize}:".blue # Outputs Noun, Verb
        meaning["definitions"].each_with_index do |definition, index|
          # Optional: Skip definitions containing restricted words
          if $restricted_words.any? { |rw| definition["definition"].downcase.include?(rw) }
            puts "  A restricted word was in the definition.".yellow
            next # Skip this definition
          end
          puts "  #{index + 1}. #{definition['definition']}"
        end
        puts "\n" # Add a blank line for readability
      end
      elsif response.code.to_i == 404
        # Custom handling for 404 error
        puts "Error: 404 - Word not found in the dictionary.".red
      else
        # Custom handling for all other errors
        puts "Error: #{response.code} - An unexpected error occurred. Please try again later.".yellow
      end
    
      rescue SocketError => e
        # Handle connection errors
        puts "Network Error: Unable to connect to the server. Please check your internet connection.".red
        puts "Details: #{e.message}".yellow
    
      rescue StandardError => e
        # Handle other unexpected errors
        puts "An unexpected error occurred: #{e.message}".red
      end
    end
end