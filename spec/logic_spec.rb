require "./lib/logic.rb"

describe Logic do
  describe "#bishop_moves" do
    it "returns all & only legal moves for a bishop with no pieces blocking it" do

    end

    it "returns all & only legal moves for a bishop blocked by allied pieces" do

    end

    it "returns all & only legal moves for a bishop that can take enemy pieces" do

    end

    it "returns an empty array for a bishop with no legal moves" do

    end
  end

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

  describe "#find" do
    it "returns the location of a piece on the board" do

    end

    it "returns nil for a piece which is not on the board" do

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

  describe "#king_moves" do
    it "returns all & only legal moves for a king with no pieces blocking it" do

    end

    it "returns all & only legal moves for a king blocked by allied pieces" do

    end

    it "returns all & only legal moves for a king that can take enemy pieces" do

    end

    it "returns an empty array for a king with no legal moves" do

    end
  end

  describe "#knight_moves" do
    it "returns all & only legal moves for a knight with no pieces blocking it" do

    end

    it "returns all & only legal moves for a knight near the edge of the board" do

    end

    it "returns all & only legal moves for a knight blocked by allied pieces" do

    end

    it "allows the knight to jump over other pieces" do

    end

    it "returns all & only legal moves for a knight that can take enemy pieces" do

    end

    it "returns an empty array for a knight with no legal moves" do

    end
  end

  describe "#mate?" do
    it "returns true when the player has been checkmated" do

    end

    it "returns false when the player is in check, but not checkmate" do

    end

    it "returns false when the player is in neither check nor checkmate" do

    end
  end

  describe "#pawn_moves" do
    context "when pawn is white" do
      it "returns both moves for an unblocked pawn that hasn't moved" do

      end

      it "returns one move for an unblocked pawn that has moved" do

      end

      it "includes diagonal moves for a pawn that can take enemy pieces" do

      end

      it "does not allow a pawn to move or attack backwards" do

      end
    end

    context "when pawn is black" do
      it "returns both moves for an unblocked pawn that hasn't moved" do

      end

      it "returns one move for an unblocked pawn that has moved" do

      end

      it "includes diagonal moves for a pawn that can take enemy pieces" do

      end

      it "does not allow a pawn to move or attack backwards" do

      end
    end
  end

  describe "#queen_moves" do
    it "returns all & only legal moves for a queen with no pieces blocking it" do

    end

    it "returns all & only legal moves for a queen blocked by allied pieces" do

    end

    it "returns all & only legal moves for a queen that can take enemy pieces" do

    end

    it "returns an empty array for a queen with no legal moves" do

    end
  end

  describe "rook_moves" do
    it "returns all & only legal moves for a rook with no pieces blocking it" do

    end

    it "returns all & only legal moves for a rook blocked by allied pieces" do

    end

    it "returns all & only legal moves for a rook that can take enemy pieces" do

    end

    it "returns an empty array for a rook with no legal moves" do

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
