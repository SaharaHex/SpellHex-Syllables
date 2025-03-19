require_relative 'display_utils' # Load the utility class
require_relative 'online_dictionary' # Load the online dictionary class
require_relative 'spellhex_dictionary' # Load the syllables dictionary class

# Load restricted words from the JSON file
OnlineDictionary.load_restricted_words('restricted_words.json')

# Function to display the menu
def display_menu  
  prompt = TTY::Prompt.new

  # Define menu choices
  choices = {
    "Search by Vowel / Syllables (beta)" => :search_by_vowel,
    "Look up Online Dictionary" => :online_dictionary,
    "Clear Screen" => :clear_screen,
    "Exit" => :exit
  }

  DisplayUtils.welcome_message() # About text

  # Menu loop
  loop do
    DisplayUtils.print_horizontal_line() # Prints a blue line of 100 characters (from display_utils class)
    # Display the menu and get user input
    user_choice = prompt.select("Choose an option:", choices)

    case user_choice
    when :search_by_vowel
      puts "You selected 'Search by Vowel / Syllables'."
      letter = DisplayUtils.select_letter
      vowels_list = SpellHexDictionary.get_all_vowels() # Get the available list of Vowels
      vowel = DisplayUtils.select_vowel(vowels_list)
      syllables = DisplayUtils.select_syllables()
      category_list = SpellHexDictionary.get_all_categories() # Get the available list of Categories
      category = DisplayUtils.select_category(category_list)
      SpellHexDictionary.query_dictionary(letter.upcase, vowel, syllables, category) # Run search on Syllables Dictionary
    when :online_dictionary
      DisplayUtils.print_horizontal_line('-', :green, 100) # Prints a green line of 100 characters (from display_utils class)
      puts "Enter word to Search Online Dictionary:"
      word = gets.chomp
      SpellHexDictionary.get_word_vowel(word.downcase) # Run search on Syllables Dictionary
      OnlineDictionary.search_online_dictionary(word) # Run search on Online Dictionary
    when :clear_screen
      system("clear") || system("cls") # Clear console for UNIX or Windows systems
    when :exit
      if prompt.yes?("Are you sure you want to exit?")
        break
      end
    end
  end
end

# Starting function
display_menu