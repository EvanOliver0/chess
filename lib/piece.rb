class Piece
  attr_reader :name, :color, :symbol, :value, :has_moved

  def initialize(name:, color:, symbol:, value:)
    @name = name
    @color = color
    @symbol = symbol
    @value = value
    @has_moved = false
  end

  def move
    @has_moved = true
  end
end
