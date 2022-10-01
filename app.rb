require 'colorize'

# this module is used to get a one character long string
module GetChar
  def self.char_get
    char = String.new
    loop do
      char = gets.chomp
      break if char.length == 1 && char != '•'
      puts "Invalid sign. You should input just 1 character which isn't a '•' sign".red
    end
    char # return the character
  end
end

# this class is made to start a game, create players and a board
class Game
  include GetChar

  # start a new game
  def self.start_new_game
    puts "#{"Hello!".yellow} You're about to play an implementation of Tic-Tac-Toe game by #{"Valdemar_check".yellow} (e.g. me)"
    sleep(3)
    puts "To get started, both players should choose their #{"'cell signs'".yellow}"
    sleep(2)
    create_players
    create_board
  end

  # create a player
  def self.create_player(player_num, avoid=nil)
    puts "#{"Player #{player_num}".yellow}, choose your sign"
    player = nil
    loop do # creates a player until it's chosen 'sign' is 'appropriate'
      player = Player.new(GetChar.char_get)
      break unless player.cell_character.eql?(avoid) # break if new player's sign matches someone else's sign
      puts "Your character should be different from other players' characters".red
    end
    player # return the player
  end

  # create 2 players
  def self.create_players
    @player1 = create_player(1)
    @player2 = create_player(2, @player1.cell_character)
  end

  # create a board
  def self.create_board
    @board = Board.new(@player1.cell_character, @player2.cell_character)
    @board.play # start the game
  end

end

# each instance of this class keeps it's player sign inside of it
class Player
  attr_reader :cell_character

  def initialize(cell_character)
    @cell_character = cell_character
  end
end

# this class almost entirely affects the current game
class Board
  include GetChar
  attr_reader :player1_cell, :player2_cell, :insides, :switch

  def initialize(player1_cell, player2_cell)
    @player1_cell = player1_cell
    @player2_cell = player2_cell
    @switch = false # this variable is made to switch between 2 players
  end

  # starts a game session
  def play
    set_cells # fill the board with cells
    loop do
      round # play a round
      break if draw?
      winner_num = find_winner # check if there is a winner
      break if winner_num.eql?('1') || winner_num.eql?('2')
    end
    announce_draw if draw?
    announce_winner(winner_num) # announce a winner and stop current game session
  end

  private

  # fill the board with cells
  def set_cells
    @insides = Array.new(9) { Cell.new('•')}
  end

  # get a certain cell on the board
  def get_cell
    loop do
      sleep(0.2)
      puts "Input a number between 1 and #{@insides.length}"
      code = gets.chomp
      if code.match(/^[1-#{@insides.length}]$/) # checks if chosen number is between 1 and board's size (9)
        # return a cell if it's free
        return @insides[code.to_i - 1] if @insides[code.to_i - 1].content != @player1_cell && @insides[code.to_i - 1].content != @player2_cell
        puts 'The chosen cell MUST be free'.red
        sleep(0.2)
      else
        puts "Invalid cell number. Choose a number between 0 and #{@insides.length}".red
        sleep(0.2)
      end
    end
  end

  # sets a chosen cell to current player's sign
  def set_cell(cell, player_char)
    cell.content = player_char
  end

  # prints a board in the console
  def print_board
    cells_printed = 0
    @insides.each do |cell|
      print "|#{cell.content}|"
      cells_printed += 1
      print "\n" if (cells_printed % 3).zero? # switch to a new line if 3 cells where printed on the current line
    end
  end

  # plays a round
  def round
    print_board
    player_num = (@switch == false) ? 1 : 2 # chooses a player
    sleep(0.2)
    puts "#{"Player #{player_num}".yellow}, choose a cell"
    cell = get_cell # choose a cell and return it

    if @switch == false # choose which player is currently playing (1 or 2)
      set_cell(cell, @player1_cell)
      @switch = true
    else
      set_cell(cell, @player2_cell)
      @switch = false
    end
  end

  # checks if there is a winner
  def find_winner
    simple_board = [] # replace all objects with integers (1 for 1st player's cell and 2 for 2nd player's cell)
    @insides.each do |cell|
      cell_sign = cell.content
      if cell_sign == @player1_cell
        simple_board.push(1)
      elsif cell_sign == @player2_cell
        simple_board.push(2)
      else # append 0 if the cell is free
        simple_board.push(0)
      end
    end
    winner_num = get_winner(simple_board) # get a number of a winner
    announce_winner(winner_num) if winner_num.between?(1, 2) # announce a winner if there is any
    return nil
  end

  # returns a number of a winner if there is any
  def get_winner(simple_board)
    winner_num = 0
    (0...simple_board.length).each do |i| # go through a simplified board
      # check for 3 same signs in a row
      if simple_board[i] == simple_board[i + 1] && simple_board[i + 1] == simple_board[i + 2]
        winner_num = simple_board[i]
        break
      # check for 3 same signs in a column
      elsif simple_board[i] == simple_board[i + 3] && simple_board[i + 3] == simple_board[i + 6]
        winner_num = simple_board[i]
        break
      # check for 3 same signs in diagonal
      elsif simple_board[i] == simple_board[i + 4] && simple_board[i + 4] == simple_board[i + 8]
        winner_num = simple_board[i]
        break
      end
    end
    winner_num
  end

  # checks if the game session results into draw
  def draw?
    # return true if there is no winner but the game board is full
    return true if @insides.length == 9 && !find_winner
  end

  # announces 'draw' and ends the game session
  def announce_draw
    puts "It's a draw! Wanna play again?".green
    ask_for_restart
  end

  # prints a winner and ends the game session
  def announce_winner(winner_num)
    puts "#{"Player #{winner_num} has won!".yellow} Wanna play again?".green
    ask_for_restart
  end

  # ask a player if he wants to play again
  def ask_for_restart
    puts "Print 'y' for restart and 'n' for ending the session"
    char = String.new
    loop do
      char = GetChar.char_get.downcase # get user's input
      break if char == 'y' || char == 'n'
      puts "Invalid answer. Print either 'y' or 'n'".red
    end
    case char
    when 'y' # start a brand new game session
      Game.start_new_game
    when 'n' # quit altogether
      puts 'See you next time!'.yellow
      exit(0)
    end
  end
end

# each instance of this class keeps it's content (sign) inside of it
class Cell
  attr_accessor :content

  def initialize(content)
    @content = content
  end
end

# start the game for the first time
Game.start_new_game
