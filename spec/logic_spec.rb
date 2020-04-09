require "./lib/logic.rb"

describe Logic do
  describe "#bishop_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @subject = instance_double("piece")
      allow(@subject).to receive(:color).and_return("white")
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
      @spaces = setup( [ [2, 3], [1, 6], [6, 7], [7, 0] ], "white" )
      expected = [[2, 5], \
                  [4, 5], [5, 6], \
                  [4, 3], [5, 2], [6, 1]]

      moves = Logic.bishop_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a bishop that can take enemy pieces" do
      @spaces = setup( [ [2, 3], [1, 6], [6, 7], [7, 0] ], "black" )
      expected = [[2, 3], \
                  [2, 5], [1, 6], \
                  [4, 5], [5, 6], [6, 7], \
                  [4, 3], [5, 2], [6, 1], [7, 0]]

      moves = Logic.bishop_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a bishop with no legal moves" do
      @spaces = setup( [ [0, 1], [1, 1], [1, 0] ], "white" )
      expected = []

      moves = Logic.bishop_moves(@spaces, [0, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#check?" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @king = instance_double("piece")
      allow(@king).to receive(:color).and_return("black")
      allow(@king).to receive(:name).and_return("king")

      @pawn = instance_double("piece")
      allow(@pawn).to receive(:color).and_return("black")
      allow(@pawn).to receive(:name).and_return("pawn")

      @enemy_queen = instance_double("piece")
      allow(@enemy_queen).to receive(:color).and_return("white")
      allow(@enemy_queen).to receive(:name).and_return("queen")

      @player = instance_double("player")
      allow(@player).to receive(:color).and_return("black")
      allow(@player).to receive(:pieces).and_return( {king: @king} )
    end

    it "returns true when the player's king is in check" do
      @spaces[4][7] = @king
      @spaces[4][0] = @enemy_queen

      expect(Logic.check?(@spaces, @player)).to be_true
    end

    it "returns false when the player's king is not in check" do
      @spaces[4][7] = @king
      @spaces[3][0] = @enemy_queen

      expect(Logic.check?(@spaces, @player)).to be_false
    end

    it "returns false when the a potential check is blocked" do
      @spaces[4][7] = @king
      @spaces[4][0] = @enemy_queen
      @spaces[4][1] = @pawn

      expect(Logic.check?(@spaces, @player)).to be_false
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

      @subject = instance_double("piece")
      allow(@subject).to receive(:color).and_return("white")
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
      @spaces = setup( [ [2, 3], [3, 5], [4, 5] ], "white" )
      expected = [[2, 4], [2, 5], \
                  [3, 3], \
                  [4, 3], [4, 4]]

      moves = Logic.king_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a king that can take enemy pieces" do
      @spaces = setup( [ [2, 3], [3, 5], [4, 5] ], "black" )
      expected = [[2, 3], [2, 4], [2, 5], \
                  [3, 3], [3, 5], \
                  [4, 3], [4, 4], [4, 5]]

      moves = Logic.king_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a king with no legal moves" do
      @spaces = setup( [ [3, 0], [3, 1], [4, 1], [5, 0], [5, 1] ], "white" )
      expected = []

      moves = Logic.king_moves(@spaces, [4, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#knight_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @subject = instance_double("piece")
      allow(@subject).to receive(:color).and_return("white")
    end

    it "returns all & only legal moves for a knight with no pieces blocking it" do
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight near the edge of the board" do
      expected = [ [0, 4], [2, 4], [3, 5], [3, 7] ]

      moves = Logic.knight_moves(@spaces, [1, 6], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight blocked by allied pieces" do
      @spaces = setup( [ [4, 2], [5, 3], [1, 3] ], "white" )
      expected = [[2, 2], [1, 5], [2, 6], [4, 6], [5, 5]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "allows the knight to jump over other pieces" do
      @spaces = setup( [ [2, 4], [4, 4] ], "white" )
      @spaces = setup( [ [3, 3], [3, 5] ], "black" )
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a knight that can take enemy pieces" do
      @spaces = setup( [ [4, 2], [5, 3], [1, 3] ], "black" )
      expected = [[2, 2], [1, 3], [1, 5], [2, 6], [4, 6], [5, 5], [5, 3], [4, 2]]

      moves = Logic.knight_moves(@spaces, [3, 4], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a knight with no legal moves" do
      @spaces = setup( [ [1, 5], [2, 6] ], "white" )
      expected = []

      moves = Logic.knight_moves(@spaces, [0, 7], @subject)
      expect(moves).to match_array(expected)
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
      before(:each) do
        @spaces = Array.new(8) { Array.new(8) }

        @subject = instance_double("piece")
        allow(@subject).to receive(:color).and_return("white")
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
        @spaces = setup( [ [1, 4], [3, 4] ], "black" )
        moves = Logic.pawn_moves(@spaces, [2, 3], @subject)
        expect(moves).to match_array([[2, 4], [1, 4], [3, 4]])
      end

      it "does not allow a pawn to move or attack backwards" do
        @spaces = setup( [ [1, 4], [3, 4] ], "black" )
        moves = Logic.pawn_moves(@spaces, [2, 5], @subject)
        expect(moves).to match_array([[2, 6]])
      end
    end

    context "when pawn is black" do
      before(:each) do
        @spaces = Array.new(8) { Array.new(8) }

        @subject = instance_double("piece")
        allow(@subject).to receive(:color).and_return("black")
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
        @spaces = setup( [ [1, 3], [3, 3] ], "white" )
        moves = Logic.pawn_moves(@spaces, [2, 4], @subject)
        expect(moves).to match_array([[2, 3], [1, 3], [3, 3]])
      end

      it "does not allow a pawn to move or attack backwards" do
        @spaces = setup( [ [1, 4], [3, 4] ], "white" )
        moves = Logic.pawn_moves(@spaces, [2, 3], @subject)
        expect(moves).to match_array([[2, 2]])
      end
    end
  end

  describe "#queen_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @subject = instance_double("piece")
      allow(@subject).to receive(:color).and_return("white")
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
      @spaces = setup( [ [0, 0], [1, 3], [3, 4] ], "white" )
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
      @spaces = setup( [ [0, 0], [1, 3], [3, 4] ], "black" )
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
      @spaces = setup( [ [2, 0], [2, 1], [3, 1], [4, 1], [4, 0] ], "white" )
      expected = []

      moves = Logic.queen_moves(@spaces, [3, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "rook_moves" do
    before(:each) do
      @spaces = Array.new(8) { Array.new(8) }

      @subject = instance_double("piece")
      allow(@subject).to receive(:color).and_return("white")
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
      @spaces = setup( [ [2, 3], [3, 5], [7, 3] ], "white" )
      expected = [[3, 4], \
                  [4, 3], [5, 3], [6, 3], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.rook_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns all & only legal moves for a rook that can take enemy pieces" do
      @spaces = setup( [ [2, 3], [3, 5], [7, 3] ], "black" )
      expected = [[2, 3], \
                  [3, 4], [3, 5], \
                  [4, 3], [5, 3], [6, 3], [7, 3], \
                  [3, 0], [3, 1], [3, 2]]

      moves = Logic.rook_moves(@spaces, [3, 3], @subject)
      expect(moves).to match_array(expected)
    end

    it "returns an empty array for a rook with no legal moves" do
      @spaces = setup( [ [0, 1], [1, 1], [1, 0] ], "white" )
      expected = []

      moves = Logic.rook_moves(@spaces, [0, 0], @subject)
      expect(moves).to match_array(expected)
    end
  end

  describe "#threats_to" do
    before(:each) do
      @black_pawn = instance_double("piece")
      allow(@black_pawn).to receive(:name).and_return("pawn")
      allow(@black_pawn).to receive(:color).and_return("black")
      allow(@black_pawn).to receive(:to_s).and_return("BP")

      @white_knight = instance_double("piece")
      allow(@white_knight).to receive(:name).and_return("knight")
      allow(@white_knight).to receive(:color).and_return("white")
      allow(@white_knight).to receive(:to_s).and_return("WN")

      @black_bishop = instance_double("piece")
      allow(@black_bishop).to receive(:name).and_return("bishop")
      allow(@black_bishop).to receive(:color).and_return("black")
      allow(@black_bishop).to receive(:to_s).and_return("BB")

      @white_rook = instance_double("piece")
      allow(@white_rook).to receive(:name).and_return("rook")
      allow(@white_rook).to receive(:color).and_return("white")
      allow(@white_rook).to receive(:to_s).and_return("WR")

      @black_queen = instance_double("piece")
      allow(@black_queen).to receive(:name).and_return("queen")
      allow(@black_queen).to receive(:color).and_return("black")
      allow(@black_queen).to receive(:to_s).and_return("BQ")

      @white_king = instance_double("piece")
      allow(@white_king).to receive(:name).and_return("king")
      allow(@white_king).to receive(:color).and_return("white")
      allow(@white_king).to receive(:to_s).and_return("WK")

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
      puts 1
      puts threats
      expect(threats).to match_array([@black_pawn, @white_knight, @black_bishop, @white_rook, @black_queen, @white_king])
    end

    it "returns an empty array when nothing is threatening the space" do
      threats = Logic.threats_to(@spaces, [1, 0])
      puts 2
      puts threats
      expect(threats).to match_array([])
    end

    it "does not include the occupant if the space is occupied" do
      @spaces[2][3] = nil
      @spaces[3][4] = @white_king
      puts 3
      threats = Logic.threats_to(@spaces, [3, 4])
      puts threats
      expect(threats).to match_array([@black_pawn, @white_knight, @black_bishop, @white_rook, @black_queen])
    end
  end

  def setup(positions, color)
    spaces = Array.new(8) { Array.new(8) }

    mock = instance_double("piece")
    allow(mock).to receive(:color).and_return(color)

    positions.each do |rank, file|
      spaces[rank][file] = mock
    end

    return spaces
  end
end
