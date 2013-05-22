#!/usr/bin/env ruby

class Game
  LETTER_HASH = {}
  ("a".."h").each {|letter| LETTER_HASH[letter] = letter.ord - 97}
  attr_accessor :player1, :player2, :board
  #creates two human players
  #gets two names
  #Assigns black or white to each
  #
  # initialize starting positions
  def initialize
    @board = Board.new
    @knight = Knight.new('white',[7, 1])
    put_piece(@knight)
  end

  def play
    @player1 = HumanPlayer.new
    @player2 = HumanPlayer.new

    puts "Name of Player 1 (white)?"
    name1 = gets.chomp
    @player1.name = name1
    @player1.color = "white"

    puts "Name of Player 2 (black)?"
    name2 = gets.chomp
    @player2.name = name2
    @player2.color = "black"

  end

  # Puts Piece Method(piece, coordinates)
  def put_piece(piece)
    y = piece.position.first
    x = piece.position.last
    @board.chessboard[y][x] = piece
  end


  # move logic
  #convert coordinates to game


  def convert_coordinates(coord)
    start_pos, end_pos = coord.split(',')

    start_col = LETTER_HASH[start_pos[0]]
    start_row = 8 - start_pos[1].to_i

    end_col = LETTER_HASH[end_pos[0]]
    end_row = 8 - end_pos[1].to_i
    [[start_row, start_col], [end_row, end_col]]
  end

  def get_input
    puts "#{@player1.name} input coordinates (e.g. \"f2,f8\") ..."
    coord = gets.chomp
    convert_coordinates(coord)
  end

  def move
    start_pos, end_pos = get_input
    p "start_pos is #{start_pos}"
    piece = @board.chessboard[start_pos[0]][start_pos[1]]
    piece.position = end_pos
    @board.update_board(start_pos, end_pos)
  end

  #should keep track of whose move it is
  #as well as the board
  #check/mate
  #murder piece

end

class Board

  attr_accessor :chessboard, :piece_at
  # initialize grid
  def initialize
    @chessboard = Array.new(8) {Array.new(8) {' '}}
    # @chessboard.each_with_index do |row, idx1|
    #   row.each_with_index do |el, idx2|
    #     p "in the loop"
    #     @chessboard[idx1][idx2] = idx1 + idx2
    #   end
    # end
  end

  def piece_at(coordinate)

  end

  # display_board
  def display_board
    puts "  +----+----+----+----+----+----+----+----+"

    @chessboard.each_with_index do |row, idx|
      temp_row = row.map do |el|
        if el.class == String
          el
        elsif el.class.superclass == Piece
          el.symbol
        end
      end
      puts "#{8 - idx} |  " + temp_row.join(' |  ') + ' |'
      puts "  +----+----+----+----+----+----+----+----+"
    end

    puts "     a    b    c    d    e    f    g    h  "
  end

  def move_piece(piece, end_position)


  end

  def update_board(start_pos, end_pos)
    piece = @chessboard[start_pos[0]][start_pos[1]]
    @chessboard[end_pos[0]][end_pos[1]] = piece
    @chessboard[start_pos[0]][start_pos[1]] = " "
  end

  # update_board
  # occupied
end

class HumanPlayer
  attr_accessor :name, :color
  # get_user_input_from_self
  # black or white

  def initialize

  end

end

class Piece
  attr_accessor :color, :position
  def initialize(color, position)
    @color = color
    @position = position

  end
  #black or white piece
  #current_position
  #move


end

class Pawn < Piece
  #inherits Piece methods
  #valid_move?
  #calls Piece::check_coord

end

class Knight < Piece
  attr_accessor :symbol

  def initialize(color, position)
    super(color, position)
    @symbol = color == 'white' ? "N" : "*N"
  end
  #inherits Piece methods
  #valid_move? -> Knight::possible_moves


end

class Rook < Piece
  #inherits Piece methods
  #valid_move?

end

class Queen < Piece
  #inherits Piece methods
  #valid_move?

end

class King < Piece
  #inherits Piece methods
  #valid_move?
  #King::possible_moves
  #check?

end

class Bishop < Piece
  #inherits Piece methods
  #valid_move?

end

if __FILE__ == $PROGRAM_NAME
  newgame = Game.new
  newgame.play
  newgame.board.display_board
  newgame.move
  newgame.board.display_board
end
