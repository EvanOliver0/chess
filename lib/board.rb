require "./lib/piece.rb"
require "./lib/player.rb"

class Board
  attr_reader :spaces, :players, :victor

  def initialize(white_human: true, black_human: true)
    @spaces = Array.new(8) { Array.new(8) }
    set_up_pieces()
    @players = []
    @players << Player.new(color: "white", human: white_human)
    @players << Player.new(color: "black", human: black_human)
    @victor = nil
  end

  def current_player
    return @players[0]
  end

  def find_moves(piece, start)
    case piece.name
    when "pawn"
      return pawn_moves(start, piece.has_moved)
    when "knight"
      return knight_moves(start)
    when "bishop"
      return bishop_moves(start)
    when "rook"
      return rook_moves(start)
    when "queen"
      return queen_moves(start)
    when "king"
      return king_moves(start)
    else
      raise RuntimeError, "Unknown piece: #{piece.name}"
    end
  end

  def make_move(move)
    move_info = decode_move(move)
    type = move_info[0]
    start_coords = move_info[1..2]
    end_coords = move_info[3..4]

    piece = @spaces[start_coords[0]][start_coords[1]]
    return [false, "There is no piece there to move!"] if piece.nil?

    if piece.name != type
      return [false, "There's no #{type} at that space. Did you mean to move the #{piece.name}?"]
    end

    valid_moves = find_moves(piece, start_coords)
    return [false, "That piece can't move like that."] unless valid_moves.include? end_coords

    target = @spaces[end_coords[0]][end_coords[1]]
    @spaces[end_coords[0]][end_coords[1]] = piece
    @spaces[start_coords[0]][start_coords[1]] = nil
    message = target.nil? ? move : move.sub("-", "x")

    if check?(current_player)
      @spaces[end_coords[0]][end_coords[1]] = target
      @spaces[start_coords[0]][start_coords[1]] = piece
      return [false, "You can't allow your own king to be in check!"]
    end

    if check?(@players[1])
      if mate?(@players[1])
        message += "#\n"
        message += current_player.color == "white" ? "1-0" : "0-1"
        victor = current_player
        return [true, message]
      else
        message += "+"
      end
    end

    return [true, message]
  end

  private
  def check?(player)
    return false
  end

  def decode_move(move)
    pieces = {"P": "pawn", "N": "knight", "B": "bishop", "R": "rook", "Q": "queen", "K": "king"}
    files = {"a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7}

    if move[0] == move[0].upcase
      piece_code = move[0]
      move = move[1..-1]
    else
      piece_code = "P"
    end

    start, target = move.split("-") if move.include?("-")
    start, target = move.split("x")

    return [pieces[piece_code], files[start[0]], start[1].to_i, files[target[0]], target[1].to_i]
  end

  def pawn_moves(start, has_moved)
    moves = []
    moves << [start[0], start[1] + 1] if start[1] < 7
    moves << [start[0], start[1] + 2] unless has_moved
    return moves
  end

  def knight_moves(start)
    offsets = [ [ 2, -1], [ 1, -2], [-1, -2], [-2, -1], \
                [-2,  1], [-1,  2], [ 1,  2], [ 2,  1] ]
    moves = []

    offsets.each do |offset|
      file = start[0] + offset[0]
      rank = start[1] + offset[1]
      if file >= 0 && file < @spaces.size && rank >= 0 && rank < @spaces.size
        moves << [file, rank]
      end
    end

    return moves
  end

  def bishop_moves(start)
    moves = []

    file, rank = start
    until file >= @spaces.size || rank >= @spaces.size do
      file, rank = file + 1, rank + 1
      moves << [file, rank]
    end

    file, rank = start
    until file < 0 || rank >= @spaces.size do
      file, rank = file - 1, rank + 1
      moves << [file, rank]
    end

    file, rank = start
    until file >= @spaces.size || rank < 0 do
      file, rank = file + 1, rank - 1
      moves << [file, rank]
    end

    file, rank = start
    until file < 0 || rank < 0 do
      file, rank = file - 1, rank - 1
      moves << [file, rank]
    end
  end

  def rook_moves(start)
    moves = []

    8.times { |file| moves << [file, start[1]] unless file == start[0] }
    8.times { |rank| moves << [start[0], rank] unless rank == start[1] }

    return moves
  end

  def queen_moves(start)
    moves = bishop_moves(start)
    moves.concat rook_moves(start)
    return moves
  end

  def king_moves(start)
    files = [start[0]]
    files << (start[0] - 1) unless start[0] == 0
    files << (start[0] + 1) unless start[0] == 7

    ranks = [start[1]]
    ranks << (start[1] - 1) unless start[1] == 0
    ranks << (start[1] + 1) unless start[1] == 7

    moves = []
    files.each { |file| ranks.each { |rank| moves << [file, rank] unless [file, rank] == start } }

    return moves
  end

  def mate?(player)
    return false
  end

  def set_up_pieces
    @spaces[0][0] = Piece.rook(color: "white")
    @spaces[1][0] = Piece.knight(color: "white")
    @spaces[2][0] = Piece.bishop(color: "white")
    @spaces[3][0] = Piece.queen(color: "white")
    @spaces[4][0] = Piece.king(color: "white")
    @spaces[5][0] = Piece.bishop(color: "white")
    @spaces[6][0] = Piece.knight(color: "white")
    @spaces[7][0] = Piece.rook(color: "white")
    @spaces[0][1] = Piece.pawn(color: "white")
    @spaces[1][1] = Piece.pawn(color: "white")
    @spaces[2][1] = Piece.pawn(color: "white")
    @spaces[3][1] = Piece.pawn(color: "white")
    @spaces[4][1] = Piece.pawn(color: "white")
    @spaces[5][1] = Piece.pawn(color: "white")
    @spaces[6][1] = Piece.pawn(color: "white")
    @spaces[7][1] = Piece.pawn(color: "white")
    @spaces[0][7] = Piece.rook(color: "black")
    @spaces[1][7] = Piece.knight(color: "black")
    @spaces[2][7] = Piece.bishop(color: "black")
    @spaces[3][7] = Piece.queen(color: "black")
    @spaces[4][7] = Piece.king(color: "black")
    @spaces[5][7] = Piece.bishop(color: "black")
    @spaces[6][7] = Piece.knight(color: "black")
    @spaces[7][7] = Piece.rook(color: "black")
    @spaces[0][6] = Piece.pawn(color: "black")
    @spaces[1][6] = Piece.pawn(color: "black")
    @spaces[2][6] = Piece.pawn(color: "black")
    @spaces[3][6] = Piece.pawn(color: "black")
    @spaces[4][6] = Piece.pawn(color: "black")
    @spaces[5][6] = Piece.pawn(color: "black")
    @spaces[6][6] = Piece.pawn(color: "black")
    @spaces[7][6] = Piece.pawn(color: "black")
  end
end
