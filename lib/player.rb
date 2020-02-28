class Player
  attr_reader :color

  def initialize(color:, human: true)
    @color = color
    @human = human
  end

  def get_move(board: nil)
    return @human ? ask_move : generate_move(board)
  end

  private
  def ask_move(input: STDIN, output: STDOUT)
    move = ""
    valid = false
    until valid do
      output.print "#{color.capitalize}'s move: "
      move = input.gets.chomp
      valid = valid_move? move
      output.puts "Invalid move! Try again." unless valid
    end
    return move
  end

  def generate_move(board)
    raise(ArgumentError, "get_move requires board argument for AI player") if board.nil?
  end

  def to_s
    return "#{@color.capitalize} (#{@human ? 'human' : 'AI'})"
  end
end
