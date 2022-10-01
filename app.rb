require 'colorize'

module GetChar
  def self.char_get
    char = String.new
    loop do
      char = gets.chomp
      break if char.length == 1 && char != '•'
      puts "Invalid sign. You should input just 1 character which isn't a '•' sign".red
    end
    char
  end
end

class Game
  include GetChar
  def self.start_new_game
    puts "#{"Hello!".yellow} You're about to play an implementation of Tic-Tac-Toe game by #{"Valdemar_check".yellow} (e.g. me)"
    sleep(3)
    puts "To get started, both players should choose their #{"'cell signs'".yellow}"
    sleep(2)
    create_players
    create_board
  end

  def self.create_player(player_num, avoid=nil)
    puts "#{"Player #{player_num}".yellow}, choose your sign"
    player = nil
    loop do
      player = Player.new(GetChar.char_get)
      break unless player.cell_character.eql?(avoid)
      puts "Your character should be different from other players' characters".red
    end
    player
  end

  def self.create_players
    @player1 = create_player(1)
    @player2 = create_player(2, @player1.cell_character)
  end

  def self.create_board
    @board = Board.new(@player1.cell_character, @player2.cell_character)
    @board.play
  end

end

class Player
  attr_reader :cell_character

  def initialize(cell_character)
    @cell_character = cell_character
  end
end

class Board
  include GetChar
  attr_reader :player1_cell, :player2_cell, :insides, :switch

  def initialize(player1_cell, player2_cell)
    @player1_cell = player1_cell
    @player2_cell = player2_cell
    @switch = false
  end

  def play
    set_cells
    loop do
      round
      winner_num = find_winner
      break if winner_num.eql?('1') || winner_num.eql?('2')
    end
    announce_winner(winner_num)
  end

  private

  def set_cells
    @insides = Array.new(9) { Cell.new('•')}
  end

  def get_cell
    loop do
      sleep(0.2)
      puts "Input a number between 1 and #{@insides.length}"
      code = gets.chomp
      if code.match(/^[1-#{@insides.length}]$/)
        return @insides[code.to_i - 1] if @insides[code.to_i - 1].content != @player1_cell && @insides[code.to_i - 1].content != @player2_cell
        puts 'The chosen cell MUST be free'.red
        sleep(0.2)
      else
        puts "Invalid cell number. Choose a number between 0 and #{@insides.length}".red
        sleep(0.2)
      end
    end
  end

  def set_cell(cell, player_char)
    cell.content = player_char
  end

  def print_board
    cells_printed = 0
    @insides.each do |cell|
      print "|#{cell.content}|"
      cells_printed += 1
      print "\n" if (cells_printed % 3).zero?
    end
  end

  def round
    print_board
    player_num = (@switch == false) ? 1 : 2
    sleep(0.2)
    puts "#{"Player #{player_num}".yellow}, choose a cell"
    cell = get_cell

    if @switch == false
      set_cell(cell, @player1_cell)
      @switch = true
    else
      set_cell(cell, @player2_cell)
      @switch = false
    end
  end

  def find_winner
    simple_board = [] 
    @insides.each do |cell|
      cell_sign = cell.content
      if cell_sign == @player1_cell
        simple_board.push(1)
      elsif cell_sign == @player2_cell
        simple_board.push(2)
      else
        simple_board.push(0)
      end
    end
    winner_num = get_winner(simple_board)
    announce_winner(winner_num) if winner_num.between?(1, 2)
  end

  def get_winner(simple_board)
    winner_num = 0
    (0...simple_board.length).each do |i|
      if simple_board[i] == simple_board[i + 1] && simple_board[i + 1] == simple_board[i + 2]
        winner_num = simple_board[i]
        break
      elsif simple_board[i] == simple_board[i + 3] && simple_board[i + 3] == simple_board[i + 6]
        winner_num = simple_board[i]
        break
      elsif simple_board[i] == simple_board[i + 4] && simple_board[i + 4] == simple_board[i + 8]
        winner_num = simple_board[i]
        break
      end
    end
    winner_num
  end

  def announce_winner(winner_num)
    puts "#{"Player #{winner_num} has won!".yellow} Wanna play again?"
    ask_for_restart
  end

  def ask_for_restart
    puts "Print 'y' for restart and 'n' for ending the session"
    char = String.new
    loop do
      char = GetChar.char_get.downcase
      break if char == 'y' || char == 'n'
      puts "Invalid answer. Print either 'y' or 'n'".red
    end
    case char
    when 'y'
      Game.start_new_game
    when 'n'
      puts 'See you next time!'.yellow
      exit(0)
    end
  end
end

class Cell
  attr_accessor :content

  def initialize(content)
    @content = content
  end
end

Game.start_new_game
