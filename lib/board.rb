require './lib/moves.rb'

class Board

    attr_accessor :chess_board
    attr_accessor :player
    attr_reader :pices
    
    @@CHESS_SYMBOLS = {
        :w_king => "\u2654 ",
        :w_queen => "\u2655 ",
        :w_rook => "\u2656 ",
        :w_bishop => "\u2657 ",
        :w_knight => "\u2658 ",
        :w_pawn => "\u2659 ",
        :b_king => "\u265A ",
        :b_queen => "\u265B ",
        :b_rook => "\u265C ",
        :b_bishop => "\u265D ",
        :b_knight => "\u265E ",
        :b_pawn => "\u265F "
    }
    
    # character row for the chess board
    @@ROW = ["a", "b", "c", "d", "e", "f", "g", "h"]

    def initialize(player, chess_board = nil)
        @player = player
        # start value for chess board
        if chess_board.nil?
            @chess_board = [
                [@@CHESS_SYMBOLS[:w_rook], @@CHESS_SYMBOLS[:w_knight], @@CHESS_SYMBOLS[:w_bishop], @@CHESS_SYMBOLS[:w_queen], @@CHESS_SYMBOLS[:w_king], @@CHESS_SYMBOLS[:w_bishop], @@CHESS_SYMBOLS[:w_knight], @@CHESS_SYMBOLS[:w_rook]],
                Array.new(8, @@CHESS_SYMBOLS[:w_pawn]),
                Array.new(8, "  "),
                Array.new(8, "  "),
                Array.new(8, "  "),
                Array.new(8, "  "),
                Array.new(8, @@CHESS_SYMBOLS[:b_pawn]),    
                [@@CHESS_SYMBOLS[:b_rook], @@CHESS_SYMBOLS[:b_knight], @@CHESS_SYMBOLS[:b_bishop], @@CHESS_SYMBOLS[:b_king], @@CHESS_SYMBOLS[:b_queen], @@CHESS_SYMBOLS[:b_bishop], @@CHESS_SYMBOLS[:b_knight], @@CHESS_SYMBOLS[:b_rook]]
            ]
        else
            @chess_board = chess_board
        end

        if @player == "w"
            # all white pices
            @pices = ["\u2654 ", "\u2655 ", "\u2656 ", "\u2657 ", "\u2658 ", "\u2659 "]
        else
            # all black pices
            @pices = ["\u265A ", "\u265B ", "\u265C ", "\u265D ", "\u265E ", "\u265F "]
        end
    end

    def print_board(pos = nil)
        possible_moves = get_possible_moves(pos)
        puts " ┌――――――――――――――――――――――――――――――――┐"
       @chess_board.each_with_index do |line, index|
            print "#{8-index}|"  
            line.each_with_index do |block, i|
                # make the picked pice background yellow
                if @@ROW[i]+(8-index).to_s == pos
                    print "\u001b[43m #{block} \u001b[0m" 
                # Draw a green circle
                elsif possible_moves.include?(@@ROW[i]+(8-index).to_s)
                    # block is empty (draw a green circle with the same background)
                    if block == "  "
                        if (index+i).odd?
                            print "\u001b[40m \u001b[92m\u2B24  \u001b[0m"
                        else
                            print "\u001b[47m \u001b[92m\u2B24  \u001b[0m"
                        end
                    # block have a value make its background green
                    else
                        print "\u001b[42m #{block} \u001b[0m"
                    end  
                
                # the value is not a possible move
                elsif (index+i).odd?
                    print "\u001b[40m #{block} \u001b[0m" 
                else
                    print "\u001b[47m #{block} \u001b[0m"
                end
            end
            print "|\n"
        end
        puts " └――――――――――――――――――――――――――――――――┘\n" + "   " + @@ROW.join("   ")
    end
     
    def move_pice(from, to)
        from = from.split("")
        to = to.split("")
        
        # move the pice to the selected position 
        tmp = @chess_board[8-from.last.to_i][@@ROW.index(from.first)] 
        @chess_board[8-from.last.to_i][@@ROW.index(from.first)] = "  "
        @chess_board[8-to.last.to_i][@@ROW.index(to.first)] = tmp

    end
    
    def get_possible_moves(pos, king = true)
        return Array.new() if pos.nil?

        pos = pos.split("")
        Moves.new(self, 
            @@CHESS_SYMBOLS.key(@chess_board[8-pos.last.to_i][@@ROW.index(pos.first)]),
            pos, king).possible_moves
    end

    def get_all_player_pices(opponent = false)
        all = []
        if opponent
            @chess_board.each_with_index do |line, index|
                line.each_with_index do |block, i|
                    all.push([@@ROW[i]+(8-index).to_s, block]) if !(["  "]+@pices).include?(block)
                end
            end
        else
            @chess_board.each_with_index do |line, index|
                line.each_with_index do |block, i|
                    all.push([@@ROW[i]+(8-index).to_s, block]) if @pices.include?(block) && !get_possible_moves(@@ROW[i]+(8-index).to_s).empty?
                end
            end
        end

        all
    end

    def get_king_position 
        if @player == 'w'
            king = "\u2654 "
        else
            king = "\u265A "
        end

        king_pos = nil
        #find the player's king
        @chess_board.each_with_index do |line, index|
            line.each_with_index do |block, i|
                if block == king
                    king_pos = @@ROW[i]+(8-index).to_s
                    break
                end
            end
        end
        king_pos
    end


    # get the row arr
    def row
        return @@ROW
    end
end
