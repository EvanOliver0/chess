require "./lib/board.rb"

describe Board do
  describe "#check?" do
    it "returns true when the player's king is in check" do

    end

    it "returns false when the player's king is not in check" do

    end
  end

  describe "#decode_move" do
    it "turns long algebraic notation into [type, file0, rank0, file1, rank1]" do

    end

    it "works for pawns without the type being specified" do

    end

    it "works when using x instead of -" do

    end
  end

  describe "#find_moves" do
    it "finds all possible moves for a king" do

    end

    it "finds all possible moves for a queen" do

    end

    it "finds all possible moves for a rook" do

    end

    it "finds all possible moves for a bishop" do

    end

    it "finds all possible moves for a knight" do

    end

    it "finds all possible moves for a pawn that hasn't moved" do

    end

    it "finds all possible moves for a pawn that has moved" do

    end

    it "finds all possible moves for a pawn that can take a piece" do

    end
  end

  describe "#make_move" do
    it "returns [false, error_message] when given incomprehensible input" do

    end

    it "returns [false, error_message] when there is no piece at start" do

    end

    it "returns [false, error_message] when player doesn't own piece at start" do

    end

    it "returns [false, error_message] when piece at start doesn't match specified type" do

    end

    it "returns [false, error_message] when the move is illegal" do

    end

    it "returns [false, error_message] when the move would put player's king in check" do

    end

    it "returns [true, move_code] when the move is valid" do

    end

    it "makes the move when the move is valid" do

    end
  end

  describe "#threats_to" do
    it "returns an array of all pieces threatening the space at the given coordinates" do

    end

    it "returns an empty array when nothing is threatening the space" do

    end

    it "does not include the occupant if the space is occupied" do

    end
  end
end
