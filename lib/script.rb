# frozen-string-literal: true

require 'yaml'
# This class stores the required variables for the game
class Game
  attr_accessor :reference, :guess, :count

  def initialize(reference, count = 0,  _=0)
    @duplicate = reference.split(//)
    @reference = reference.split(//)
    @count = count
    @guess = Array.new(reference.length, '_')
  end

  def to_yaml
    YAML.dump({
      :reference => @reference,
      :count => @count,
      :guess => @guess,
      :duplicate => @duplicate
    })
  end

  def self.from_yaml(string)
    data = YAML.load_file(string)
    puts 'got here'
    p data
    self.new(data[:reference].join(''), data[:count], data[:guess])
  end

  def check_win
    @duplicate == @guess
  end

  def check_letter(letter)
    num = @reference.index(letter) 
    if !num.nil? && @guess[num] == '_'
      puts 'Hooray, You got a letter'
      @guess[num] = letter
      @reference[num] = '_'
    else
      puts 'No match'
    end
  end
end

def word
  word_list = File.readlines('dictionary.txt').map!(&:chomp).select! { |word| word.length.between?(5, 12) }
  word_list[rand(word_list.length - 1)]
end

def user_input(file)
  puts 'Do you want to'
  puts '[1] start a new game'
  puts 'OR'
  puts '[2] load and existing game?'
  choice = gets.chomp!.to_i
  existing = File.exist?(file) && !File.zero?(file)
  if choice == 1
    choice
  elsif choice == 2 && existing
    choice
  else
    puts 'invalid input'
    user_input(file)
  end
end

def save(game)
  new_file = File.open('saved_file.yaml', 'w')
  new_file.print game.to_yaml
  new_file.close
end

def start
  choice = user_input('saved_file.yaml')
  if choice == 1
    Game.new(word)
  else
    Game.from_yaml('saved_file.yaml')
  end
end

def valid_input
  choice = gets.chomp.downcase
  return choice if choice == 'save'
  return choice if choice.length == 1 && choice.match?(/[A-Za-z]/)

  puts 'Invalid input, try again'
  valid_input
end


game = start
won = false
puts game.reference
until won || game.count > 9
  puts game.guess.join('')
  puts 'Enter your guess'
  guess = valid_input
  if guess == 'save'
    save(game)
    break
  end
  game.check_letter(guess)
  game.count += 1
  won = game.check_win
end

if won
  puts 'Hooray, you won the game'
else
  puts 'You lost'
end

