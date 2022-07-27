require './lib/board.rb'

class Moves

    @@stop = false

    def initialize(board, symbol, pos, king)
        @board = board
        @chess_board = @board.chess_board
        @row_arr = @board.row
        @symbol = symbol
        @pos = [8-pos.last.to_i, @row_arr.index(pos.first)]
        @player = @board.player
        @pices = @board.pices
        @king = king
        @all = Array.new
    end

    def possible_moves
        if [:b_king, :w_king].include?(@symbol) && @king
            king()
        elsif [:b_queen, :w_queen].include?(@symbol) 
            # queen movement is the compination of rook and bishop movement
            rook()
            bishop()
        elsif [:b_rook, :w_rook].include?(@symbol) 
            rook()
        elsif [:b_knight, :w_knight].include?(@symbol) 
            knight() 
        elsif [:b_bishop, :w_bishop].include?(@symbol) 
            bishop() 
        elsif 
            pawn()
        end

        # remove all positions that will cause checkmate
        # @@stop to prevent looping
        # exclude the king because it will delete its own moves 
        if @@stop == false && ![:b_king, :w_king].include?(@symbol)
            pos = @row_arr[@pos.last] + (8-(@pos.first)).to_s
            remove_positions = Array.new

            @all.each do |new_pos|
                #change the color of the player to find the opponent moves
                @player == 'w' ? color = 'b' : color = 'w'
                # deep copy of board object
                @board_copy = Marshal.load( Marshal.dump(Board.new(color, @chess_board)) )
        
                # move the pice to new position and check if your opponent can attack your king 
                @board_copy.move_pice(pos, new_pos)

                @@stop = true
                new_pos_arr = new_pos.split("")
                new_pos_arr = [8-new_pos_arr.last.to_i, @row_arr.index(new_pos_arr.first)]
                remove_positions.push(new_pos) if get_opponent_move(true).include?(@board.get_king_position) && !@pices.include?(@chess_board[new_pos_arr.first][new_pos_arr.last])

            end

            @@stop = false
            @all -= remove_positions

        end

        return @all
    end

    private
    def king
        all_opponent_moves = get_opponent_move()
        
        # move down:1, not checkmate
        @all.push(@row_arr[@pos.last] + (8-(@pos.first+1)).to_s) if @pos.first+1 < 8 && !@pices.include?(@chess_board[(@pos.first+1)][@pos.last]) && !all_opponent_moves.include?(@row_arr[@pos.last] + (8-(@pos.first+1)).to_s)
        # move up:1
        @all.push(@row_arr[@pos.last] + (8-(@pos.first-1)).to_s) if @pos.first-1 >= 0 && !@pices.include?(@chess_board[(@pos.first-1)][@pos.last]) && !all_opponent_moves.include?(@row_arr[@pos.last] + (8-(@pos.first-1)).to_s)
        # move right:1
        @all.push(@row_arr[@pos.last+1] + (8-(@pos.first)).to_s) if @pos.last+1 < 8 && !@pices.include?(@chess_board[(@pos.first)][@pos.last+1]) && !all_opponent_moves.include?(@row_arr[@pos.last+1] + (8-(@pos.first)).to_s)
        # move left:1
        @all.push(@row_arr[@pos.last-1] + (8-(@pos.first)).to_s) if @pos.last-1 >= 0 && !@pices.include?(@chess_board[(@pos.first)][@pos.last-1]) && !all_opponent_moves.include?(@row_arr[@pos.last-1] + (8-(@pos.first)).to_s)
        # move up:1, left:1
        @all.push(@row_arr[@pos.last-1] + (8-(@pos.first-1)).to_s) if @pos.last-1 >= 0 && @pos.first-1 >= 0 && !@pices.include?(@chess_board[(@pos.first-1)][@pos.last-1]) && !all_opponent_moves.include?(@row_arr[@pos.last-1] + (8-(@pos.first-1)).to_s)
        # move up:1, right:1
        @all.push(@row_arr[@pos.last+1] + (8-(@pos.first-1)).to_s) if @pos.last+1 < 8 && @pos.first-1 >= 0 && !@pices.include?(@chess_board[(@pos.first-1)][@pos.last+1]) && !all_opponent_moves.include?(@row_arr[@pos.last+1] + (8-(@pos.first-1)).to_s)
        # move down:1, right:1
        @all.push(@row_arr[@pos.last+1] + (8-(@pos.first+1)).to_s) if @pos.last+1 < 8 && @pos.first+1 < 8 && !@pices.include?(@chess_board[(@pos.first+1)][@pos.last+1]) && !all_opponent_moves.include?(@row_arr[@pos.last+1] + (8-(@pos.first+1)).to_s)
        # move down:1, left:1
        @all.push(@row_arr[@pos.last-1] + (8-(@pos.first+1)).to_s) if @pos.last-1 >= 0 && @pos.first+1 < 8 && !@pices.include?(@chess_board[(@pos.first+1)][@pos.last-1]) && !all_opponent_moves.include?(@row_arr[@pos.last-1] + (8-(@pos.first+1)).to_s)
    end

    def rook
        # up
        (1).upto(8-@pos.first-1) do |i| 
            # continue next step is empty
            if @chess_board[(@pos.first+i)][@pos.last] == "  "
                @all.push(@row_arr[@pos.last] + (8-(@pos.first+i)).to_s)
            # stop when next step our pices
            elsif @pices.include?(@chess_board[(@pos.first+i)][@pos.last])
                break
            # next step is enemy pice
            else
                @all.push(@row_arr[@pos.last] + (8-(@pos.first+i)).to_s) 
                break
            end
        end

        #down
        (1).upto(@pos.first) do |i| 
            # continue next step is empty
            if @chess_board[(@pos.first-i)][@pos.last] == "  "
                @all.push(@row_arr[@pos.last] + (8-(@pos.first-i)).to_s)
            # stop when next step our pices
            elsif @pices.include?(@chess_board[(@pos.first-i)][@pos.last])
                break
            # next step is enemy pice
            else
                @all.push(@row_arr[@pos.last] + (8-(@pos.first-i)).to_s) 
                break
            end
        end

        #left
        (1).upto(8 - @pos.last-1) do |i| 
            # continue next step is empty
            if @chess_board[(@pos.first)][@pos.last+i] == "  "
                @all.push(@row_arr[@pos.last+i] + (8-(@pos.first)).to_s)
            # stop when next step our pices
            elsif @pices.include?(@chess_board[(@pos.first)][@pos.last+i])
                break
            # next step is enemy pice
            else
                @all.push(@row_arr[@pos.last+i] + (8-(@pos.first)).to_s) 
                break
            end
        end
        
        #right
        (1).upto(@pos.last) do |i| 
            # continue next step is empty
            if @chess_board[(@pos.first)][@pos.last-i] == "  "
                @all.push(@row_arr[@pos.last-i] + (8-(@pos.first)).to_s)
            # stop when next step our pices
            elsif @pices.include?(@chess_board[(@pos.first)][@pos.last-i])
                break
            # next step is enemy pice
            else
                @all.push(@row_arr[@pos.last-i] + (8-(@pos.first)).to_s) 
                break
            end
        end
    end

    def knight
        # move: 2-up/1-right
        @all.push(@row_arr[@pos.last+1] + (8-(@pos.first+2)).to_s) if @pos.first + 2 < 8 && @pos.last + 1 < 8 && !@pices.include?(@chess_board[(@pos.first+2)][@pos.last+1])
        # move: 2-up/1-left
        @all.push(@row_arr[@pos.last-1] + (8-(@pos.first+2)).to_s) if @pos.first + 2 < 8 && @pos.last - 1 >= 0 && !@pices.include?(@chess_board[(@pos.first+2)][@pos.last-1])
        # move: 1-up/2-right
        @all.push(@row_arr[@pos.last+2] + (8-(@pos.first+1)).to_s) if @pos.first + 1 < 8 && @pos.last + 2 < 8 && !@pices.include?(@chess_board[(@pos.first+1)][@pos.last+2])
        # move: 1-up/2-left
        @all.push(@row_arr[@pos.last-2] + (8-(@pos.first+1)).to_s) if @pos.first + 1 < 8 && @pos.last - 2 >= 0 && !@pices.include?(@chess_board[(@pos.first+1)][@pos.last-2])
        # move: 2-down/1-right
        @all.push(@row_arr[@pos.last+1] + (8-(@pos.first-2)).to_s) if @pos.first - 2 >= 0 && @pos.last + 1 < 8 && !@pices.include?(@chess_board[(@pos.first-2)][@pos.last+1])
        # move: 2-down/1-left
        @all.push(@row_arr[@pos.last-1] + (8-(@pos.first-2)).to_s) if @pos.first - 2 >= 0 && @pos.last - 1 >= 0 && !@pices.include?(@chess_board[(@pos.first-2)][@pos.last-1])
        # move: 1-down/2-right
        @all.push(@row_arr[@pos.last+2] + (8-(@pos.first-1)).to_s) if @pos.first - 1 >= 0 && @pos.last + 2 < 8 && !@pices.include?(@chess_board[(@pos.first-1)][@pos.last+2])
        # move: 1-down/2-left
        @all.push(@row_arr[@pos.last-2] + (8-(@pos.first-1)).to_s) if @pos.first - 1 >= 0 && @pos.last - 2 >= 0 && !@pices.include?(@chess_board[(@pos.first-1)][@pos.last-2])
    end

    def bishop
        # up, right
        (1).upto(8-@pos.first-1) do |i| 
            if @pos.last+i < 8
                # continue next step is empty
                if @chess_board[(@pos.first+i)][@pos.last+i] == "  "
                    @all.push(@row_arr[@pos.last+i] + (8-(@pos.first+i)).to_s)
                # stop when next step our pices
                elsif @pices.include?(@chess_board[(@pos.first+i)][@pos.last+i])
                    break
                # next step is enemy pice
                else
                    @all.push(@row_arr[@pos.last+i] + (8-(@pos.first+i)).to_s) 
                    break
                end
            end
        end
        
        # up,left
        (1).upto(@pos.first) do |i|
            if @pos.last+i < 8
                # continue next step is empty
                if @chess_board[(@pos.first-i)][@pos.last+i] == "  "
                    @all.push(@row_arr[@pos.last+i] + (8-(@pos.first-i)).to_s)
                # stop when next step our pices
                elsif @pices.include?(@chess_board[(@pos.first-i)][@pos.last+i])
                    break
                # next step is enemy pice
                else
                    @all.push(@row_arr[@pos.last+i] + (8-(@pos.first-i)).to_s) 
                    break
                end
            end
        end

        # down,left
        (1).upto(@pos.first) do |i|
            if @pos.last-i >= 0
                # continue next step is empty
                if @chess_board[(@pos.first-i)][@pos.last-i] == "  "
                    @all.push(@row_arr[@pos.last-i] + (8-(@pos.first-i)).to_s)
                # stop when next step our pices
                elsif @pices.include?(@chess_board[(@pos.first-i)][@pos.last-i])
                    break
                # next step is enemy pice
                else
                    @all.push(@row_arr[@pos.last-i] + (8-(@pos.first-i)).to_s) 
                    break
                end
            end
        end
        
        # down,right
        (1).upto(8-@pos.first-1) do |i|
            if @pos.last-i >= 0
                # continue next step is empty
                if @chess_board[(@pos.first+i)][@pos.last-i] == "  "
                    @all.push(@row_arr[@pos.last-i] + (8-(@pos.first+i)).to_s)
                # stop when next step our pices
                elsif @pices.include?(@chess_board[(@pos.first+i)][@pos.last-i])
                    break
                # next step is enemy pice
                else
                    @all.push(@row_arr[@pos.last-i] + (8-(@pos.first+i)).to_s) 
                    break
                end
            end
        end
    end

    def pawn
        # when we calculate the position for the opponent
        if (@player == "w" && @king) || (@player == "b" && @king == false)
            # move down:2
            @all.push(@row_arr[@pos.last] + (8-(@pos.first+2)).to_s) if @pos.first == 1 && (@chess_board[2][@pos.last] == "  " and @chess_board[3][@pos.last] == "  ")
            # move down:1
            @all.push(@row_arr[@pos.last] + (8-(@pos.first+1)).to_s) if @pos.first+1 < 8 && @chess_board[(@pos.first+1)][@pos.last] == "  "
            # move down:1, left:1
            @all.push(@row_arr[@pos.last+1] + (8-(@pos.first+1)).to_s) if @pos.first+1 < 8 && @pos.last+1 < 8 && (!((["  ", nil]+@pices).include?@chess_board[(@pos.first+1)][@pos.last+1]) || @king == false)
            # move down:1, right:1
            @all.push(@row_arr[@pos.last-1] + (8-(@pos.first+1)).to_s) if @pos.last-1 >= 0 && @pos.first+1 < 8 && (!((["  ", nil]+@pices).include?@chess_board[(@pos.first+1)][@pos.last-1]) || @king == false)
        
        else
            # move up:2
            @all.push(@row_arr[@pos.last] + (8-(@pos.first-2)).to_s) if @pos.first == 6 && (@chess_board[5][@pos.last] == "  " && @chess_board[4][@pos.last] == "  ")
            # move up:1
            @all.push(@row_arr[@pos.last] + (8-(@pos.first-1)).to_s) if @pos.first-1 >= 0 && @chess_board[@pos.first-1][@pos.last] == "  "
            # move up:1, right:1
            @all.push(@row_arr[@pos.last+1] + (8-(@pos.first-1)).to_s) if @pos.first-1 >= 0 && @pos.last+1 < 8 && (!((["  ", nil]+@pices).include?@chess_board[(@pos.first-1)][@pos.last+1]) || @king == false)
            # move up:1, left:1
            @all.push(@row_arr[@pos.last-1] + (8-(@pos.first-1)).to_s) if @pos.last-1 >= 0 && @pos.first-1 >= 0 && (!((["  ", nil]+@pices).include?@chess_board[(@pos.first-1)][@pos.last-1]) || @king == false)
        end
    end

    def get_opponent_move(check = false)  
        all_opponent_moves = []
        # get all opponent pices 
        @board.get_all_player_pices(true).each do |pice|
            # remove the king from the board and calculate all the position that tha opponent can reach
            if [:b_king, :w_king].include?(@symbol)
                # change the king in the board to empty cell
                tmp = @chess_board[(@pos.first)][@pos.last]
                @chess_board[(@pos.first)][@pos.last] = "  "

                all_opponent_moves += @board.get_possible_moves(pice.first, false) 
                
                @chess_board[(@pos.first)][@pos.last] = tmp

            elsif check 
                all_opponent_moves += @board_copy.get_possible_moves(pice.first) 
            else
                all_opponent_moves += @board.get_possible_moves(pice.first, false) 
            end
        end
        
        return all_opponent_moves
    end
end