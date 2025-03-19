# Utility class for display-related methods
class DisplayUtils
  require 'colorize' # for text coloring
  require 'tty-prompt' # for layout

  # Class method to print a horizontal line across the screen
  def self.print_horizontal_line(char = '=', color = :blue, width = 100)
    # Use a default width if dynamic detection isn't possible
    puts (char * width).colorize(color)
  end

  def self.select_letter
    prompt = TTY::Prompt.new
    
    # prompt for custom input
    selected_choice = prompt.ask("Please enter a Starting Letter:") do |q|
      q.validate(/^[A-Za-z]{1}$/, "Invalid input. Please enter a single letter from A to Z.") # Combined validation for a single character /^.{1}$/ that is a letter /[A-Za-z]/
    end
  end

  def self.select_vowel(vowels)
    prompt = TTY::Prompt.new

    # Create a hash to map choices to display text
    display_choices = vowels.map { |vowel| { name: "#{vowel[:name]} - #{vowel[:description]}", value: vowel[:Id] } }

    selected_vowel = prompt.select("Please choose Vowel:", display_choices)
  end

  def self.select_syllables    
    prompt = TTY::Prompt.new
  
    # Define choices as an array
    choices = ["1", "2", "3", "4+"]
  
    # Prompt the user to select a number of syllables
    user_choice = prompt.select("Select number of syllables:", choices)
  end

  def self.select_category(categories)
    prompt = TTY::Prompt.new

    # Create a hash to map choices to display text
    display_choices = categories.map { |category| { name: "#{category[:name]} - #{category[:description]}", value: category[:Id] } }

    # Add an option for All Categories
    display_choices.unshift({ name: "All Categories", value: :"0" })

    selected_category = prompt.select("Please choose Category:", display_choices)
  end

  # About text
  def self.welcome_message
    print_horizontal_line('*', :magenta, 43) # Prints a magenta line of 43 characters
    puts "⭐    Welcome to SpellHex Syllables     ⭐".bold
    print_horizontal_line('*', :magenta, 43) # Prints a magenta line of 43 characters
    puts "A spelling assistance application / "
    puts "dictionary that breaks down words into"
    puts "vowel sounds and syllables."
    print_horizontal_line('*', :magenta, 43) # Prints a magenta line of 43 characters
  end
  
end