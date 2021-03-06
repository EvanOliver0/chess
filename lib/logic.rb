class Logic
  class << self
    # Ugh. There's gotta be a way to make this more DRY.
    def bishop_moves(spaces, start, actor)
      moves = []

      file, rank = start
      until file + 1 >= spaces.size || rank + 1 >= spaces.size do
        file, rank = file + 1, rank + 1
        occupant = spaces[file][rank]
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
      until file - 1 < 0 || rank + 1 >= spaces.size do
        file, rank = file - 1, rank + 1
        occupant = spaces[file][rank]
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
      until file + 1 >= spaces.size || rank - 1 < 0 do
        file, rank = file + 1, rank - 1
        occupant = spaces[file][rank]
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
        occupant = spaces[file][rank]
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

    def can_be_blocked?(spaces, attacker, victim)
      return false if ["king", "knight", "pawn"].include? attacker.name

      rank0, file0 = find(spaces, attacker)
      rank1, file1 = find(spaces, victim)

      unless threats_to(spaces, [rank1, file1]).include? attacker
        puts "Error: attacker is not threatening victim!"
        return true
      end

      find_step = -> (pos0, pos1) {
        if pos0 == pos1
          return 0
        else
          return (pos1 - pos0) / (pos1 - pos0).abs
        end
      }

      rank_step = find_step.call(rank0, rank1)
      file_step = find_step.call(file0, file1)

      rank = rank0 + rank_step
      file = file0 + file_step
      steps = []
      until [rank, file] == [rank1, file1] do
        if rank < 0 || file < 0 || rank >= spaces.size || file >= spaces.size
          puts "Error: pathfindng missed target in method can_be_blocked?"
          puts "Steps: #{steps}"
          return true
        end

        steps << [rank, file]
        rank += rank_step
        file += file_step
      end

      steps.each do |coords|
        return true if threats_to(spaces, coords).any? { |threat| threat != victim && threat.color != attacker.color }
      end

      return false
    end

    def check?(spaces, player)
      king_coords = find(spaces, player.pieces[:king])
      threats_to(spaces, king_coords).each { |piece| return true unless piece.color == player.color }
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

    def find(spaces, piece)
      spaces.size.times do |rank|
        spaces.size.times do |file|
          return [rank, file] if spaces[rank][file] == piece
        end
      end
      return nil
    end

    def find_moves(spaces, start)
      piece = spaces[start[0]][start[1]]
      return [] if piece.nil?

      case piece.name
      when "pawn"
        return pawn_moves(spaces, start, piece)
      when "knight"
        return knight_moves(spaces, start, piece)
      when "bishop"
        return bishop_moves(spaces, start, piece)
      when "rook"
        return rook_moves(spaces, start, piece)
      when "queen"
        return queen_moves(spaces, start, piece)
      when "king"
        return king_moves(spaces, start, piece)
      else
        raise RuntimeError, "Unknown piece: #{piece.name}"
      end
    end

    def king_trapped?(spaces, player)
      king_coords = find(spaces, player.pieces[:king])
      moves = king_moves(spaces, king_coords, player.pieces[:king])

      # We don't want the king "blocking" an adjacent space from attack
      spaces_no_king = spaces.map(&:dup)
      spaces_no_king[king_coords[0]][king_coords[1]] = nil

      moves.each do |move|
        return false if threats_to(spaces_no_king, move).none? { |piece| piece.color != player.color }
      end

      return true
    end

    def king_moves(spaces, start, actor)
      files = [start[0]]
      files << (start[0] - 1) unless start[0] == 0
      files << (start[0] + 1) unless start[0] == 7

      ranks = [start[1]]
      ranks << (start[1] - 1) unless start[1] == 0
      ranks << (start[1] + 1) unless start[1] == 7

      moves = []
      files.each do |file|
        ranks.each do |rank|
          occupant = spaces[file][rank]
          if occupant.nil? || occupant.color != actor.color
            moves << [file, rank] unless [file, rank] == start
          end
        end
      end

      return moves
    end

    def knight_moves(spaces, start, actor)
      offsets = [ [ 2, -1], [ 1, -2], [-1, -2], [-2, -1], \
                  [-2,  1], [-1,  2], [ 1,  2], [ 2,  1] ]
      moves = []

      offsets.each do |offset|
        file = start[0] + offset[0]
        rank = start[1] + offset[1]
        if file >= 0 && file < spaces.size && rank >= 0 && rank < spaces.size
          occupant = spaces[file][rank]
          if occupant.nil? || occupant.color != actor.color
            moves << [file, rank]
          end
        end
      end

      return moves
    end

    def mate?(spaces, player)
      spaces.size.times do |file|
        file.size.times do |rank|
          print spaces[file][rank].nil? ? "_|" : spaces[file][rank]
        end
        puts ""
      end
      puts "King in check? #{check?(spaces, player)}"
      return false unless check?(spaces, player)
      puts "King trapped? #{king_trapped?(spaces, player)}"
      return false unless king_trapped?(spaces, player)

      attackers = threats_to( spaces, find(spaces, player.pieces[:king]) ).select { |threat| threat.color != player.color }
      attackers.each do |attacker|
        puts "#{attacker.to_s}:"
        puts "Can be blocked? #{can_be_blocked?(spaces, attacker, player.pieces[:king])}"
        blockable = can_be_blocked?(spaces, attacker, player.pieces[:king])

        attacker_coords = find(spaces, attacker)
        puts "Can be taken? #{threats_to(spaces, attacker_coords).any? { |threat| threat.color == player.color }}"
        capturable = threats_to(spaces, attacker_coords).any? { |threat| threat.color == player.color }

        return true if !blockable && !capturable
      end

      return false
    end

    def pawn_moves(spaces, start, actor)
      advance = actor.color == "white" ? ->(r, n) {r + n} : ->(r, n) {r - n}
      home_rank = actor.color == "white" ? 1 : 6
      end_rank = actor.color == "white" ? 7 : 0

      moves = []
      file, rank = start

      forward_occupant = spaces[file][advance.call(rank, 1)]
      forward2_occupant = spaces[file][advance.call(rank, 2)]
      diag_left_occupant = (file == 0 || rank == end_rank) ? nil : spaces[file - 1][advance.call(rank, 1)]
      diag_right_occupant = (file == 7 || rank == end_rank) ? nil : spaces[file + 1][advance.call(rank, 1)]

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

    def queen_moves(spaces, start, actor)
      moves = bishop_moves(spaces, start, actor)
      moves.concat rook_moves(spaces, start, actor)
      return moves
    end

    # As with bishop_moves: make it DRYer.
    def rook_moves(spaces, start, actor)
      moves = []

      (start[0] - 1).downto(0) do |file|
        rank = start[1]
        occupant = spaces[file][rank]
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
        occupant = spaces[file][rank]
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
        occupant = spaces[file][rank]
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
        occupant = spaces[file][rank]
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

    def threats_to(spaces, coords)
      threats = []
      spaces.size.times do |rank|
        spaces.size.times do |file|
          piece = spaces[rank][file]
          threats << piece if (!piece.nil?) && (find_moves(spaces, [rank, file]).include? coords)
        end
      end
      return threats
    end

  end
end
