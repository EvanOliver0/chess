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
