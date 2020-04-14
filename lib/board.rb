require "./lib/logic.rb"
require "./lib/piece.rb"
require "./lib/player.rb"

class Board
  attr_reader :spaces, :players, :victor

  def initialize(white_human: true, black_human: true)
    @spaces = Array.new(8) { Array.new(8) }
    @players = []
    @players << Player.new(color: "white", human: white_human)
    @players << Player.new(color: "black", human: black_human)
    @victor = nil
    set_up_pieces()
  end

  def current_player
    return @players[0]
  end

  def make_move(move)
    move_info = Logic.decode_move(move)
    return [false, "Could not decode input - use long algebraic notation."] unless move_info

    type = move_info[0]
    start_coords = move_info[1..2]
    end_coords = move_info[3..4]

    piece = @spaces[start_coords[0]][start_coords[1]]
    return [false, "There is no piece there to move!"] if piece.nil?

    return [false, "That's not your piece!"] unless piece.color == current_player.color

    if piece.name != type
      return [false, "There's no #{type} at that space. Did you mean to move the #{piece.name}?"]
    end

    valid_moves = Logic.find_moves(@spaces, start_coords)
    return [false, "That piece can't move like that."] unless valid_moves.include? end_coords

    target = @spaces[end_coords[0]][end_coords[1]]
    @spaces[end_coords[0]][end_coords[1]] = piece
    @spaces[start_coords[0]][start_coords[1]] = nil
    message = target.nil? ? move : move.sub("-", "x")

    if Logic.check?(@spaces, current_player)
      @spaces[end_coords[0]][end_coords[1]] = target
      @spaces[start_coords[0]][start_coords[1]] = piece
      return [false, "You can't allow your own king to be in check!"]
    end

    if Logic.check?(@spaces, @players[1])
      if Logic.mate?(@spaces, @players[1])
        message += "#\n"
        message += current_player.color == "white" ? "1-0" : "0-1"
        victor = current_player
      else
        message += "+"
      end
    end

    @players << @players.shift

    return [true, message]
  end

  def to_s
    text = ""
    (@spaces.size - 1).downto(0) do |i|
      @spaces[i].size.times do |j|
        text += @spaces[j][i].nil? ? " " : @spaces[j][i].to_s
        text += " "
      end
      text += "\n"
    end
    return text
  end

  private
<<<<<<< HEAD
  def check?(player)
    king_coords = find(player.pieces[:king])
    threats_to(king_coords).each { |piece| return true unless piece.color == player.color }
    return false
  end

  def decode_move(move)
    pieces = {"P" => "pawn", "N" => "knight", "B" => "bishop", "R" => "rook", "Q" => "queen", "K" => "king"}
    files = {"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7}

    if move[0] == move[0].upcase
      piece_code = move[0]
      move = move[1..-1]
    else
      piece_code = "P"
    end

    if move.include?("-")
      start, target = move.split("-")
    elsif move.include?("x")
      start, target = move.split("x")
    else
      return false
    end

    return [pieces[piece_code], files[start[0]], start[1].to_i - 1, files[target[0]], target[1].to_i - 1]
  end

  def find(piece)
    @spaces.size.times do |rank|
      @spaces.size.times do |file|
        return [rank, file] if @spaces[rank][file] == piece
      end
    end
    return nil
  end

  def pawn_moves(start, actor)
    advance = actor.color == "white" ? ->(r, n) {r + n} : ->(r, n) {r - n}
    home_rank = actor.color == "white" ? 1 : 6
    end_rank = actor.color == "white" ? 7 : 0

    moves = []
    file, rank = start

    forward_occupant = @spaces[file][advance.call(rank, 1)]
    forward2_occupant = @spaces[file][advance.call(rank, 2)]
    diag_left_occupant = (file == 0 || rank == end_rank) ? nil : @spaces[file - 1][advance.call(rank, 1)]
    diag_right_occupant = (file == 7 || rank == end_rank) ? nil : @spaces[file + 1][advance.call(rank, 1)]

    if rank != end_rank && forward_occupant.nil?
      moves << [file, advance.call(rank, 1)]
    end
    if rank == home_rank && !actor.has_moved && forward_occupant.nil? && forward2_occupant.nil?
      moves << [file, advance.call(rank, 2)]
    end
    if !diag_left_occupant.nil? && diag_left_occupant.color != actor.color
      moves << [file - 1, advance.call(rank, 1)]
    end
    if !diag_right_occupant.nil? && diag_right_occupant.color != actor.color
      moves << [file + 1, advance.call(rank, 1)]
    end

    return moves
  end

  def knight_moves(start, actor)
    offsets = [ [ 2, -1], [ 1, -2], [-1, -2], [-2, -1], \
                [-2,  1], [-1,  2], [ 1,  2], [ 2,  1] ]
    moves = []

    offsets.each do |offset|
      file = start[0] + offset[0]
      rank = start[1] + offset[1]
      if file >= 0 && file < @spaces.size && rank >= 0 && rank < @spaces.size
        moves << [file, rank] unless @spaces[file][rank].color == actor.color
      end
    end

    return moves
  end

  # Ugh. There's gotta be a way to make this more DRY.
  def bishop_moves(start, actor)
    moves = []

    file, rank = start
    until file + 1 >= @spaces.size || rank + 1 >= @spaces.size do
      file, rank = file + 1, rank + 1
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    file, rank = start
    until file - 1 < 0 || rank + 1 >= @spaces.size do
      file, rank = file - 1, rank + 1
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    file, rank = start
    until file + 1 >= @spaces.size || rank - 1 < 0 do
      file, rank = file + 1, rank - 1
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    file, rank = start
    until file - 1 < 0 || rank - 1 < 0 do
      file, rank = file - 1, rank - 1
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    return moves
  end

  # As with bishop_moves: make it DRYer.
  def rook_moves(start, actor)
    moves = []

    (start[0] - 1).downto(0) do |file|
      rank = start[1]
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    (start[0] + 1).upto(7) do |file|
      rank = start[1]
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    (start[1] - 1).downto(0) do |rank|
      file = start[0]
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    (start[1] + 1).upto(7) do |rank|
      file = start[0]
      occupant = @spaces[file][rank]
      if occupant.nil?
        moves << [file, rank]
      elsif occupant.color == actor.color
        break
      else
        moves << [file, rank]
        break
      end
    end

    return moves
  end

  def queen_moves(start, actor)
    moves = bishop_moves(start, actor)
    moves.concat rook_moves(start, actor)
    return moves
  end

  def king_moves(start, actor)
    files = [start[0]]
    files << (start[0] - 1) unless start[0] == 0
    files << (start[0] + 1) unless start[0] == 7

    ranks = [start[1]]
    ranks << (start[1] - 1) unless start[1] == 0
    ranks << (start[1] + 1) unless start[1] == 7

    moves = []
    files.each do |file|
      ranks.each do |rank|
        occupant = @spaces[file][rank]
        if occupant.nil? || occupant.color != actor.color
          moves << [file, rank] unless [file, rank] == start
        end
      end
    end

    return moves
  end

  def mate?(player)
    return false unless check?(player)

    king_coords = find(player.pieces[:king])
    moves = king_moves(king_coords)

    puts "#{player.color.capitalize} kings's moves: "

    moves.each do |move|
      print "#{move}; threats: "
      p threats_to(move)
      return false if threats_to(move).none? { |piece| piece.color != player.color }
    end

    return true
  end

=======
>>>>>>> separate-logic
  def set_up_pieces
    @spaces[0][0] = @players[0].pieces[:rooks][0]
    @spaces[1][0] = @players[0].pieces[:knights][0]
    @spaces[2][0] = @players[0].pieces[:bishops][0]
    @spaces[3][0] = @players[0].pieces[:queens][0]
    @spaces[4][0] = @players[0].pieces[:king]
    @spaces[5][0] = @players[0].pieces[:bishops][1]
    @spaces[6][0] = @players[0].pieces[:knights][1]
    @spaces[7][0] = @players[0].pieces[:rooks][0]
    8.times { |i| @spaces[i][1] = @players[0].pieces[:pawns][i]}

    @spaces[0][7] = @players[1].pieces[:rooks][0]
    @spaces[1][7] = @players[1].pieces[:knights][0]
    @spaces[2][7] = @players[1].pieces[:bishops][0]
    @spaces[3][7] = @players[1].pieces[:queens][0]
    @spaces[4][7] = @players[1].pieces[:king]
    @spaces[5][7] = @players[1].pieces[:bishops][1]
    @spaces[6][7] = @players[1].pieces[:knights][1]
    @spaces[7][7] = @players[1].pieces[:rooks][0]
    8.times { |i| @spaces[i][6] = @players[1].pieces[:pawns][i]}
  end
end
