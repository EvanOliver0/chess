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

  def self.pawn(color:)
    symbol = color == "white" ? "♙" : "♟"
    return self.new(name: "pawn", color: color, symbol: symbol, value: 1)
  end

  def self.knight(color:)
    symbol = color == "white" ? "♘" : "♞"
    return self.new(name: "knight", color: color, symbol: symbol, value: 3)
  end

  def self.bishop(color:)
    symbol = color == "white" ? "♗" : "♝"
    return self.new(name: "bishop", color: color, symbol: symbol, value: 3)
  end

  def self.rook(color:)
    symbol = color == "white" ? "♖" : "♜"
    return self.new(name: "rook", color: color, symbol: symbol, value: 5)
  end

  def self.queen(color:)
    symbol = color == "white" ? "♕" : "♛"
    return self.new(name: "queen", color: color, symbol: symbol, value: 9)
  end

  def self.king(color:)
    symbol = color == "white" ? "♔" : "♚"
    return self.new(name: "king", color: color, symbol: symbol, value: 0)
  end
end
