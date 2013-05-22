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
    @knight1 = Knight.new('white',[7, 1])
    @knight2 = Knight.new('white',[7, 6])
    @knight3 = Knight.new('black',[0, 1])
    @knight4 = Knight.new('black',[0, 6])
    @bishop1 = Bishop.new('white',[7, 2])
    @bishop2 = Bishop.new('white',[7, 5])
    @bishop3 = Bishop.new('black',[0, 2])
    @bishop4 = Bishop.new('black',[0, 5])
    @rook1 = Rook.new('white',[7, 0])
    @rook2 = Rook.new('white',[7, 7])
    @rook3 = Rook.new('black',[0, 0])
    @rook4 = Rook.new('black',[0, 7])
    @queen1 = Queen.new('white',[7, 4])
    @queen2 = Queen.new('black',[0, 4])

    put_piece(@knight1)
    put_piece(@knight2)
    put_piece(@knight3)
    put_piece(@knight4)
    put_piece(@bishop1)
    put_piece(@rook1)
    put_piece(@rook2)
    put_piece(@rook3)
    put_piece(@rook4)
    put_piece(@bishop2)
    put_piece(@bishop3)
    put_piece(@bishop4)
    put_piece(@queen1)
    put_piece(@queen2)
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

    #display board and loop for user input
    @board.display_board
    while true
      begin
        move
      rescue RuntimeError => e
        puts "Here is your chance to fix your boneheaded move."
        puts "Error was: #{e.message}"
      end
    end

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
    piece = @board.chessboard[start_pos[0]][start_pos[1]]
    if piece.class == String
      raise RuntimeError.new "No piece at starting position."
    end
    unless check_possible_moves?(piece, end_pos)
      raise RuntimeError.new "This is not a possible move."
    end
    if @board.occupied_and_own?(piece, end_pos)
      raise RuntimeError.new "Your piece is there."
    end
    if piece.blocked?(@board, end_pos)
      raise RuntimeError.new "Pieces are in the way."
    end
    #rescue this error later in loop
    # adjust occupied for opponent pieces
    piece.position = end_pos
    @board.update_board(start_pos, end_pos)
    @board.display_board
  end

  def check_possible_moves?(piece, end_pos)
    piece.possible_moves.include?(end_pos)
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
    @chessboard = Array.new(8) {Array.new(8) {'  '}}
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
      puts "#{8 - idx} | " + temp_row.join(' | ') + ' |'
      puts "  +----+----+----+----+----+----+----+----+"
    end

    puts "     a    b    c    d    e    f    g    h  "
  end

  def move_piece(piece, end_position)


  end

  def update_board(start_pos, end_pos)
    piece = @chessboard[start_pos[0]][start_pos[1]]
    @chessboard[end_pos[0]][end_pos[1]] = piece
    @chessboard[start_pos[0]][start_pos[1]] = "  "
  end

  # update_board
  def occupied_and_own?(piece, pos)
    end_piece = @chessboard[pos[0]][pos[1]]
    (end_piece.class.superclass == Piece) && end_piece.color == piece.color

  end

  def occupied?(pos)
    piece = @chessboard[pos[0]][pos[1]]
    piece.class.superclass == Piece
  end

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

  def diagonal_moves
    delta = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
    diag_moves = []
    delta.each do |dy, dx|
      7.times do |i|
        diag_moves << [(position[0] + (dy * (i + 1))),
        (position[1] + (dx * (i + 1)))]
      end
    end
    diag_moves = diag_moves.select do |y,x|
      (0..7).include?(y) && (0..7).include?(x)
    end
    diag_moves
  end

  def orthogonal_moves
    delta = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    ortho_moves = []
    delta.each do |dy, dx|
      7.times do |i|
        ortho_moves << [(position[0] + (dy * (i + 1))),
        (position[1] + (dx * (i + 1)))]
      end
    end
    ortho_moves = ortho_moves.select do |y,x|
      (0..7).include?(y) && (0..7).include?(x)
    end
    p ortho_moves
    ortho_moves
  end

  def blocked?(board, end_pos) #comes after narrowing down possible_moves
    case self
    when Bishop
      spaces_to_check = diag_blocked_spaces(end_pos)
    when Rook
      spaces_to_check = ortho_blocked_spaces(end_pos)
      p spaces_to_check
    when Queen
      spaces_to_check = diag_blocked_spaces(end_pos) +
      ortho_blocked_spaces(end_pos)
    when Knight
      return false
    end
    spaces_to_check.any? {|space| board.occupied?(space)}
  end

  def ortho_blocked_spaces(end_pos)
    dy = end_pos[0] - position[0]
    dx = end_pos[1] - position[1]
    spaces_to_check = []

    if dy == 0
      if dx < 0
        dx.abs.times do |i|
          next if i == 0
          spaces_to_check << [dy, (dx.abs - i) * -1]
        end
      elsif dx > 0
        dx.abs.times do |i|
          next if i == 0
          spaces_to_check << [dy, (dx.abs - i) * 1]
        end
      end
    elsif dx == 0
      if dy < 0
        dy.abs.times do |i|
          next if i == 0
          spaces_to_check << [(dy.abs - i) * -1, dx]
        end
      elsif dy > 0
        dy.abs.times do |i|
          next if i == 0
          spaces_to_check << [(dy.abs - i) * 1, dx]
        end
      end
    end

    spaces_to_check.map! {|dy, dx| [dy + position[0], dx + position[1]]}
  end

  def diag_blocked_spaces(end_pos) #helper method for blocked?
    # generate array of spaces in the correct direction
    dy = end_pos[0] - position[0]
    dx = end_pos[1] - position[1]
    spaces_to_check = []
    p "dy and dx are #{[dy, dx]}"
    dy.abs.times do |i|
      next if i == 0
      if dy < 0 && dx < 0
        spaces_to_check << [(dy.abs - i) * -1, (dx.abs - i) * -1]
      elsif dy < 0 && dx > 0
        spaces_to_check << [(dy.abs - i) * -1, (dx.abs - i) * 1]
      elsif dy > 0 && dx < 0
        spaces_to_check << [(dy.abs - i) * 1, (dx.abs - i) * -1]
      elsif dy > 0 && dx > 0
        spaces_to_check << [(dy.abs - i) * 1, (dx.abs - i) * 1]
      end
    end
    spaces_to_check.map! {|dy, dx| [dy + position[0], dx + position[1]]}
  end

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
    @symbol = color == 'white' ? " N" : "*N"

  end

  def possible_moves
    pos_moves =
    [[-2,-1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    pos_moves.map! do |dy, dx|
      y = dy + position[0]
      x = dx + position[1]
      [y, x] if (0..7).include?(y) && (0..7).include?(x)
    end
    pos_moves.select { |el| !el.nil?}
  end

  #inherits Piece methods
end

class Rook < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? " R" : "*R"
  end

  def possible_moves
    orthogonal_moves
  end

end

class Queen < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? " Q" : "*Q"
  end

  def possible_moves
    orthogonal_moves + diagonal_moves
  end

end

class King < Piece
  #inherits Piece methods
  #valid_move?
  #King::possible_moves
  #check?

end

class Bishop < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? " B" : "*B"
  end

  def possible_moves
    diagonal_moves
  end

  #inherits Piece methods
  #valid_move?

end

if __FILE__ == $PROGRAM_NAME
  newgame = Game.new
  newgame.play
end
