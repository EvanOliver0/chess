require "lib/piece.rb"
require "lib/player.rb"

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
  def set_up_pieces
    @spaces[0][0] = Piece.rook("white")
    @spaces[1][0] = Piece.knight("white")
    @spaces[2][0] = Piece.bishop("white")
    @spaces[3][0] = Piece.queen("white")
    @spaces[4][0] = Piece.king("white")
    @spaces[5][0] = Piece.bishop("white")
    @spaces[6][0] = Piece.knight("white")
    @spaces[7][0] = Piece.rook("white")
    @spaces[0][1] = Piece.pawn("white")
    @spaces[1][1] = Piece.pawn("white")
    @spaces[2][1] = Piece.pawn("white")
    @spaces[3][1] = Piece.pawn("white")
    @spaces[4][1] = Piece.pawn("white")
    @spaces[5][1] = Piece.pawn("white")
    @spaces[6][1] = Piece.pawn("white")
    @spaces[7][1] = Piece.pawn("white")
    @spaces[0][7] = Piece.rook("black")
    @spaces[1][7] = Piece.knight("black")
    @spaces[2][7] = Piece.bishop("black")
    @spaces[3][7] = Piece.queen("black")
    @spaces[4][7] = Piece.king("black")
    @spaces[5][7] = Piece.bishop("black")
    @spaces[6][7] = Piece.knight("black")
    @spaces[7][7] = Piece.rook("black")
    @spaces[0][6] = Piece.pawn("black")
    @spaces[1][6] = Piece.pawn("black")
    @spaces[2][6] = Piece.pawn("black")
    @spaces[3][6] = Piece.pawn("black")
    @spaces[4][6] = Piece.pawn("black")
    @spaces[5][6] = Piece.pawn("black")
    @spaces[6][6] = Piece.pawn("black")
    @spaces[7][6] = Piece.pawn("black")
  end
end
