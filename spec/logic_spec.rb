require "./lib/logic.rb"

describe Logic do
  describe "#bishop_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @subject = mock_piece("bishop", "white", "WB")
    end

    it "returns all & only legal moves for a bishop with no pieces blocking it" do
      expected = [[0, 1], [1, 2], [2, 3], \
                  [2, 5], [1, 6], [0, 7], \
                  [4, 5], [5, 6], [6, 7], \
                  [4, 3], [5, 2], [6, 1], [7, 0]]

      moves = Logic.bishop_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a bishop blocked by allied pieces" do
      @spaces = set_pawns( [[2, 3], [1, 6], [6, 7], [7, 0]], "white" )
      expected = [[2, 5], \
                  [4, 5], [5, 6], \
                  [4, 3], [5, 2], [6, 1]]

      moves = Logic.bishop_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a bishop that can take enemy pieces" do
      @spaces = set_pawns( [[2, 3], [1, 6], [6, 7], [7, 0]], "black" )
      expected = [[2, 3], \
                  [2, 5], [1, 6], \
                  [4, 5], [5, 6], [6, 7], \
                  [4, 3], [5, 2], [6, 1], [7, 0]]

      moves = Logic.bishop_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a bishop with no legal moves" do
      @spaces = set_pawns( [[0, 1], [1, 1], [1, 0]], "white" )
      expected = []

      moves = Logic.bishop_moves(@spaces, [0, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#check?" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @king = mock_piece("king", "black", "BK")
      @pawn = mock_piece("pawn", "black", "BP")
      @enemy_queen = mock_piece("queen", "white", "WQ")

      @player = instance_double("player")
      allow(@player).to receive(:color).and_return("black")
      allow(@player).to receive(:pieces).and_return( {king: @king} )
    end

    it "returns true when the player's king is in check" do
      @spaces[4][7] = @king
      @spaces[4][0] = @enemy_queen

      expect(Logic.check?(@spaces, @player)).to be true
    end

    it "returns false when the player's king is not in check" do
      @spaces[4][7] = @king
      @spaces[3][0] = @enemy_queen

      expect(Logic.check?(@spaces, @player)).to be false
    end

    it "returns false when the a potential check is blocked" do
      @spaces[4][7] = @king
      @spaces[4][0] = @enemy_queen
      @spaces[4][1] = @pawn

      expect(Logic.check?(@spaces, @player)).to be false
    end
  end

  describe "#decode_move" do
    it "turns long algebraic notation into [type, file0, rank0, file1, rank1]" do
      expected = ["knight", 3, 2, 4, 0]
      expect(Logic.decode_move("Nd3-e1")).to eql(expected)
    end

    it "works for pawns without the type being specified" do
      expected = ["pawn", 0, 1, 0, 3]
      expect(Logic.decode_move("a2-a4")).to eql(expected)
    end

    it "works when using x instead of -" do
      expected = ["rook", 7, 0, 7, 7]
      expect(Logic.decode_move("Rh1-h8")).to eql(expected)
    end
  end

  describe "#find" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @piece = instance_double("piece")
    end

    it "returns the location of a piece on the board" do
      @spaces[6][5] = @piece
      expect(Logic.find(@spaces, @piece)).to eql([6, 5])
    end

    it "returns nil for a piece which is not on the board" do
      @spaces[6][5] = @piece
      expect(Logic.find(@spaces, instance_double("piece"))).to eql(nil)
    end
  end

  describe "#king_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @subject = mock_piece("king", "white", "WK")
    end

    it "returns all & only legal moves for a king with no pieces blocking it" do
      expected = [[2, 3], [2, 4], [2, 5], \
                  [3, 3], [3, 5], \
                  [4, 3], [4, 4], [4, 5]]

      moves = Logic.king_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a king near the edge of the board" do
      expected = [[3, 0], [3, 1], \
                  [4, 1], \
                  [5, 0], [5, 1]]

      moves = Logic.king_moves(@spaces, [4, 0], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a king blocked by allied pieces" do
      @spaces = set_pawns( [[2, 3], [3, 5], [4, 5]], "white" )
      expected = [[2, 4], [2, 5], \
                  [3, 3], \
                  [4, 3], [4, 4]]

      moves = Logic.king_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a king that can take enemy pieces" do
      @spaces = set_pawns( [[2, 3], [3, 5], [4, 5]], "black" )
      expected = [[2, 3], [2, 4], [2, 5], \
                  [3, 3], [3, 5], \
                  [4, 3], [4, 4], [4, 5]]

      moves = Logic.king_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a king with no legal moves" do
      @spaces = set_pawns( [[3, 0], [3, 1], [4, 1], [5, 0], [5, 1]], "white" )
      expected = []

      moves = Logic.king_moves(@spaces, [4, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#knight_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @subject = mock_piece("knight", "white", "WN")
    end

    it "returns all & only legal moves for a knight with no pieces blocking it" do
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight near the edge of the board" do
      expected = [[0, 4], [2, 4], [3, 5], [3, 7]]

      moves = Logic.knight_moves(@spaces, [1, 6], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight blocked by allied pieces" do
      @spaces = set_pawns( [[4, 2], [5, 3], [1, 3]], "white" )
      expected = [[2, 2], [1, 5], [2, 6], [4, 6], [5, 5]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "allows the knight to jump over other pieces" do
      @spaces = set_pawns( [[2, 4], [4, 4]], "white" )
      @spaces = set_pawns( [[3, 3], [3, 5]], "black" )
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight that can take enemy pieces" do
      @spaces = set_pawns( [[4, 2], [5, 3], [1, 3]], "black" )
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a knight with no legal moves" do
      @spaces = set_pawns( [[1, 5], [2, 6]], "white" )
      expected = []

      moves = Logic.knight_moves(@spaces, [0, 7], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#mate?" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @king = mock_piece("king", "black", "BK")

      @player = instance_double("player")
      allow(@player).to receive(:color).and_return("black")
      allow(@player).to receive(:pieces).and_return( {king: @king} )
    end

    it "returns true when the player has been checkmated" do
      @enemy_bishop = mock_piece("bishop", "white", "WB")
      @enemy_knight = mock_piece("knight", "white", "WN")
      @enemy_king = mock_piece("king", "white", "WK")

      @spaces[7][7] = @king
      @spaces[5][5] = @enemy_bishop
      @spaces[6][5] = @enemy_king
      @spaces[7][5] = @enemy_knight

      expect(Logic.mate?(@spaces, @player)).to be true
    end

    it "does not consider the king's 'shadow' to be a way out of checkmate" do
      @enemy_rook = mock_piece("rook", "white", "WR")

      @spaces = set_pawns( [[3, 6], [4, 6], [5, 6]], "black")
      @spaces[4][7] = @king
      @spaces[0][7] = @enemy_rook

      expect(Logic.mate?(@spaces, @player)).to be true
    end

    it "returns false when the attacker can be blocked" do
      @ally_knight = mock_piece("knight", "black", "BN")
      @enemy_bishop = mock_piece("bishop", "white", "WB")

      @spaces = set_pawns( [[4, 6], [5, 6], [5, 7]], "black")
      @spaces[4][7] = @king
      @spaces[4][4] = @ally_knight
      @spaces[1][4] = @enemy_bishop
      @spaces[1][5] = @enemy_bishop

      expect(Logic.mate?(@spaces, @player)).to be false
    end

    it "returns false when the attacker can be captured" do
      @ally_knight = mock_piece("knight", "black", "BN")
      @enemy_bishop = mock_piece("bishop", "white", "WB")

      @spaces = set_pawns( [[4, 6], [5, 6], [5, 7]], "black")
      @spaces[4][7] = @king
      @spaces[0][2] = @ally_knight
      @spaces[1][4] = @enemy_bishop
      @spaces[1][5] = @enemy_bishop

      expect(Logic.mate?(@spaces, @player)).to be false
    end

    it "returns true when the attacker is next to the king, but protected" do
      @enemy_queen = mock_piece("queen", "white", "WQ")
      @enemy_bishop = mock_piece("bishop", "white", "WB")

      @spaces[4][7] = @king
      @spaces[4][6] = @enemy_queen
      @spaces[0][2] = @enemy_bishop

      expect(Logic.mate?(@spaces, @player)).to be true
    end

    it "returns false when the player is in check, but not checkmate" do
      @enemy_rook = mock_piece("rook", "white", "WR")

      @spaces[4][7] = @king
      @spaces[0][7] = @enemy_rook
      @spaces[7][5] = @enemy_rook

      expect(Logic.mate?(@spaces, @player)).to be false
    end

    it "returns false when the player is in neither check nor checkmate" do
      @enemy_rook = mock_piece("rook", "white", "WR")

      @spaces[4][7] = @king
      @spaces[0][0] = @enemy_rook
      @spaces[7][0] = @enemy_rook

      expect(Logic.mate?(@spaces, @player)).to be false
    end
  end

  describe "#pawn_moves" do
    context "when pawn is white" do
      before(:each) do
        @spaces = Array.new(8) { Array.new(8) }
        @subject = mock_piece("pawn", "white", "WP")
      end

      it "returns both moves for an unblocked pawn that hasn't moved" do
        allow(@subject).to receive(:has_moved).and_return(false)
        moves = Logic.pawn_moves(@spaces, [0, 1], @subject)
        expect(moves).to match_array([[0, 2], [0, 3]])
      end

      it "returns one move for an unblocked pawn that has moved" do
        allow(@subject).to receive(:has_moved).and_return(true)
        moves = Logic.pawn_moves(@spaces, [2, 3], @subject)
        expect(moves).to match_array([[2, 4]])
      end

      it "includes diagonal moves for a pawn that can take enemy pieces" do
        @spaces = set_pawns( [[1, 4], [3, 4]], "black" )
        moves = Logic.pawn_moves(@spaces, [2, 3], @subject)
        expect(moves).to match_array([[2, 4], [1, 4], [3, 4]])
      end

      it "does not allow a pawn to move or attack backwards" do
        @spaces = set_pawns( [[1, 4], [3, 4]], "black" )
        moves = Logic.pawn_moves(@spaces, [2, 5], @subject)
        expect(moves).to match_array([[2, 6]])
      end
    end

    context "when pawn is black" do
      before(:each) do
        @spaces = Array.new(8) { Array.new(8) }
        @subject = mock_piece("pawn", "black", "BP")
      end

      it "returns both moves for an unblocked pawn that hasn't moved" do
        allow(@subject).to receive(:has_moved).and_return(false)
        moves = Logic.pawn_moves(@spaces, [0, 6], @subject)
        expect(moves).to match_array([[0, 5], [0, 4]])
      end

      it "returns one move for an unblocked pawn that has moved" do
        allow(@subject).to receive(:has_moved).and_return(true)
        moves = Logic.pawn_moves(@spaces, [2, 4], @subject)
        expect(moves).to match_array([[2, 3]])
      end

      it "includes diagonal moves for a pawn that can take enemy pieces" do
        @spaces = set_pawns( [[1, 3], [3, 3]], "white" )
        moves = Logic.pawn_moves(@spaces, [2, 4], @subject)
        expect(moves).to match_array([[2, 3], [1, 3], [3, 3]])
      end

      it "does not allow a pawn to move or attack backwards" do
        @spaces = set_pawns( [[1, 4], [3, 4]], "white" )
        moves = Logic.pawn_moves(@spaces, [2, 3], @subject)
        expect(moves).to match_array([[2, 2]])
      end
    end
  end

  describe "#queen_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @subject = mock_piece("queen", "white", "WQ")
    end

    it "returns all & only legal moves for a queen with no pieces blocking it" do
      expected = [[0, 0], [1, 1], [2, 2], \
                  [0, 3], [1, 3], [2, 3], \
                  [2, 4], [1, 5], [0, 6], \
                  [3, 4], [3, 5], [3, 6], [3, 7], \
                  [4, 4], [5, 5], [6, 6], [7, 7], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [4, 2], [5, 1], [6, 0], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.queen_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a queen blocked by allied pieces" do
      @spaces = set_pawns( [[0, 0], [1, 3], [3, 4]], "white" )
      expected = [[1, 1], [2, 2], \
                  [2, 3], \
                  [2, 4], [1, 5], [0, 6], \
                  [4, 4], [5, 5], [6, 6], [7, 7], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [4, 2], [5, 1], [6, 0], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.queen_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a queen that can take enemy pieces" do
      @spaces = set_pawns( [[0, 0], [1, 3], [3, 4]], "black" )
      expected = [[0, 0], [1, 1], [2, 2], \
                  [1, 3], [2, 3], \
                  [2, 4], [1, 5], [0, 6], \
                  [3, 4], \
                  [4, 4], [5, 5], [6, 6], [7, 7], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [4, 2], [5, 1], [6, 0], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.queen_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a queen with no legal moves" do
      @spaces = set_pawns( [[2, 0], [2, 1], [3, 1], [4, 1], [4, 0]], "white" )
      expected = []

      moves = Logic.queen_moves(@spaces, [3, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "rook_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }
      @subject = mock_piece("rook", "white", "WR")
    end

    it "returns all & only legal moves for a rook with no pieces blocking it" do
      expected = [[0, 3], [1, 3], [2, 3], \
                  [3, 4], [3, 5], [3, 6], [3, 7], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.rook_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a rook blocked by allied pieces" do
      @spaces = set_pawns( [[2, 3], [3, 5], [7, 3]], "white" )
      expected = [[3, 4], \
                  [4, 3], [5, 3], [6, 3], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.rook_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a rook that can take enemy pieces" do
      @spaces = set_pawns( [[2, 3], [3, 5], [7, 3]], "black" )
      expected = [[2, 3], \
                  [3, 4], [3, 5], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.rook_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a rook with no legal moves" do
      @spaces = set_pawns( [[0, 1], [1, 1], [1, 0]], "white" )
      expected = []

      moves = Logic.rook_moves(@spaces, [0, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#threats_to" do
    before(:each) do
      @black_pawn = mock_piece("pawn", "black", "BP")
      @white_knight = mock_piece("knight", "white", "WN")
      @black_bishop = mock_piece("bishop", "black", "BB")
      @white_rook = mock_piece("rook", "white", "WR")
      @black_queen = mock_piece("queen", "black", "BQ")
      @white_king = mock_piece("king", "white", "WK")

      @spaces = Array.new(8) { Array.new(8) }
      @spaces[0][4] = @white_rook
      @spaces[1][6] = @black_bishop
      @spaces[2][3] = @white_king
      @spaces[4][5] = @black_pawn
      @spaces[5][3] = @white_knight
      @spaces[7][4] = @black_queen
    end

    it "returns an array of all pieces threatening the space at the given coordinates" do
      threats = Logic.threats_to(@spaces, [3, 4])
      ids = threats.map { |threat| threat.to_s }
      expect(ids).to match_array(["BP", "WN", "BB", "WR", "BQ", "WK"])
    end

    it "returns an empty array when nothing is threatening the space" do
      threats = Logic.threats_to(@spaces, [1, 0])
      ids = threats.map { |threat| threat.to_s }
      expect(ids).to match_array([])
    end

    it "does not include the occupant if the space is occupied" do
      @spaces[2][3] = nil
      @spaces[3][4] = @white_king
      threats = Logic.threats_to(@spaces, [3, 4])
      ids = threats.map { |threat| threat.to_s }
      expect(ids).to match_array(["BP", "WN", "BB", "WR", "BQ"])
    end
  end

  def mock_piece(name, color, text)
    piece = instance_double("piece")
    allow(piece).to receive(:name).and_return(name)
    allow(piece).to receive(:color).and_return(color)
    allow(piece).to receive(:to_s).and_return(text)

    return piece
  end

  def set_pawns(positions, color)
    spaces = Array.new(8) { Array.new(8) }

    mock = mock_piece("pawn", color, color[0].upcase + "P")
    allow(mock).to receive(:has_moved).and_return(false)

    positions.each do |rank, file|
      spaces[rank][file] = mock
    end

    return spaces
  end
end
