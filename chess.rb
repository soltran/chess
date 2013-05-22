#!/usr/bin/env ruby

class Game
  LETTER_HASH = {}
  ("a".."h").each {|letter| LETTER_HASH[letter] = letter.ord - 97}
  attr_accessor :player1, :player2, :board, :current_player
  #creates two human players
  #gets two names
  #Assigns black or white to each
  #
  # initialize starting positions
  def initialize
    @board = Board.new
    @white_king = King.new('white',[7, 4])
    @black_king = King.new('black',[0, 4])
    @board.put_piece(@white_king)
    @board.put_piece(@black_king)
    @turn = 0
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
      @current_player = @turn % 2 == 0? @player1: @player2
      p "#{current_player.name}'s turn..."
      begin
        if checked? && checkmate?
          p "Checkmate! #{current_player.name} loses!"
          break
        end
        p "You are in check" if checked?
        move

      rescue RuntimeError => e
        puts "Here is your chance to fix your boneheaded move."
        puts "Error was: #{e.message}"
      end


    end

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
    end_piece = @board.chessboard[end_pos[0]][end_pos[1]]
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
      raise RuntimeError.new "Either pieces are in the way or there are no
      pieces to capture for your pawn"
    end

    # adjust occupied for opponent pieces
    piece.position = end_pos

    piece.first_move = false if piece.class == Pawn
    @board.update_board(start_pos, end_pos)

    if checked?
      unmove(piece, end_piece, start_pos, end_pos)
      raise RuntimeError.new "Either still in check or moving into check."
    end

    @board.display_board
    @turn += 1
  end

  def unmove(piece, end_piece, start_pos, end_pos)
    @board.chessboard[start_pos[0]][start_pos[1]] = piece
    @board.chessboard[end_pos[0]][end_pos[1]] = end_piece
    piece.position = start_pos
  end

  def checked?
    end_pos = @white_king.position if @current_player.color == "white"
    end_pos = @black_king.position if @current_player.color == "black"

    @board.chessboard.each_with_index do |row, idx1|
      row.each_with_index do |col, idx2|
        piece = @board.chessboard[idx1][idx2]
        next if piece.class == String || piece.color == @current_player.color

        if check_possible_moves?(piece, end_pos) &&
          !piece.blocked?(@board, end_pos)

          return true
        end
      end
    end

    false
  end

  def valid_moves(piece)
    legal_moves = piece.possible_moves

    legal_moves = legal_moves.select do |move|
      !@board.occupied_and_own?(piece, move) &&
      !piece.blocked?(@board, move)
    end

    legal_moves
  end

  def checkmate?
    bool_array = []
    @board.chessboard.each_with_index do |row, idx1|
      row.each_with_index do |col, idx2|

        piece = @board.chessboard[idx1][idx2]
        next if piece.class == String || piece.color != @current_player.color
        legal_moves = valid_moves(piece)

        legal_moves.each do |move|
          start_pos = piece.position
          end_piece = @board.chessboard[move[0]][move[1]]
          piece.position = move
          @board.update_board(start_pos, move)

          bool_array << checked?

          unmove(piece, end_piece, start_pos, move)

        end
      end
    end

    bool_array.all?
  end

  def check_possible_moves?(piece, end_pos) #may be removed if not used
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
    class_array = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    pawn_array = [Pawn] * 8
    @chessboard = Array.new(8) {Array.new(8) {' '}}

    class_array.each_with_index do |cl, i|
      next if i == 4
      new_piece = cl.new('white',[7, i])
      put_piece(new_piece)
      new_piece = cl.new('black',[0, i])
      put_piece(new_piece)
    end

    pawn_array.each_with_index do |cl, i|
      new_piece = cl.new('white',[6, i])
      put_piece(new_piece)
      new_piece = cl.new('black',[1, i])
      put_piece(new_piece)
    end

  end
  # Puts Piece Method(piece, coordinates)
  def put_piece(piece)
    y = piece.position.first
    x = piece.position.last
    @chessboard[y][x] = piece
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
      puts "#{8 - idx} | " + temp_row.join('  | ') + '  |'
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
  def occupied_and_own?(piece, pos)
    end_piece = @chessboard[pos[0]][pos[1]]
    (end_piece.class.superclass == Piece) && end_piece.color == piece.color

  end

  def diag_opp_occupied?(piece, diag_pos)
    end_piece = @chessboard[diag_pos[0]][diag_pos[1]]
    (end_piece.class.superclass == Piece) && end_piece.color != piece.color
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
    ortho_moves
  end

  def blocked?(board, end_pos) #comes after narrowing down possible_moves
    case self
    when Bishop
      spaces_to_check = diag_blocked_spaces(end_pos)
    when Rook
      spaces_to_check = ortho_blocked_spaces(end_pos)
    when Queen
      spaces_to_check = diag_blocked_spaces(end_pos) +
      ortho_blocked_spaces(end_pos)
    when Knight
      return false
    when Pawn
      if end_pos[1] == position[1] #going straight
        spaces_to_check = ((color == 'white') ?
        [[-1 + position[0], position[1]]] : [[1 + position[0], position[1]]])
        if first_move
          spaces_to_check << ((color == 'white') ?
          [-2 + position[0], position[1]] : [2 + position[0], position[1]])
        end
      else #going diagonally
        return !board.diag_opp_occupied?(self, end_pos)
      end
    when King
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
  attr_accessor :symbol, :first_move

  def initialize(color, position)
    super(color, position)
    @symbol = color == 'white' ? "\u2659" : "\u265F"
    @first_move = true
  end

  def possible_moves
    pos_moves =
    [[-1, -1], [-1, 0], [-1, 1]]
    pos_moves.map! do |dy, dx|
      y = color == "white" ? dy + position[0] : -dy + position[0]
      x = dx + position[1]
      [y, x] if (0..7).include?(y) && (0..7).include?(x)
    end


    if @first_move
      two_spaces_forward = (color == "white") ?
      [-2 + position[0], position[1]] : [2 + position[0], position[1]]
      pos_moves << two_spaces_forward
    end

    pos_moves = pos_moves.select { |el| !el.nil?}
  end
  #inherits Piece methods
  #valid_move?
  #calls Piece::check_coord

end

class Knight < Piece
  attr_accessor :symbol

  def initialize(color, position)
    super(color, position)
    @symbol = color == 'white' ? "\u2658" : "\u265E"

  end

  def possible_moves
    pos_moves =
    [[-2,-1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    pos_moves.map! do |dy, dx|
      y = dy + position[0]
      x = dx + position[1]
      [y, x] if (0..7).include?(y) && (0..7).include?(x)
    end

    pos_moves = pos_moves.select { |el| !el.nil?}
  end

  #inherits Piece methods
end

class Rook < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? "\u2656" : "\u265C"
  end

  def possible_moves
    orthogonal_moves
  end

end

class Queen < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? "\u2655" : "\u265B"
  end

  def possible_moves
    orthogonal_moves + diagonal_moves
  end

end

class King < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? "\u2654" : "\u265A"
  end

  def possible_moves
    delta =
    [[-1, -1], [-1, 1], [1, -1], [1, 1], [-1, 0], [1, 0], [0, -1], [0, 1]]
    pos_moves = []

    delta.each do |dy, dx|
      pos_moves << [dy + position[0], dx + position[1]]
    end

    pos_moves = pos_moves.select do |y,x|
      (0..7).include?(y) && (0..7).include?(x)
    end

    pos_moves
  end
  #inherits Piece methods
  #valid_move?
  #King::possible_moves
  #check?

end

class Bishop < Piece
  attr_accessor :symbol

  def initialize(color,position)
    super(color, position)
    @symbol = color == 'white' ? "\u2657" : "\u265D"
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
