module Rules
    # chessboard for testing if moving any pice will cause checkmate
    def checkmate?(last_position, board = @board)
        # make sure that the king not in a risk from last movement
        board.player == "w" ? king_value = "\u265A " : king_value = "\u2654 "
        board.get_possible_moves(last_position).each do |move|
            move = move.split("")
            if board.chess_board[8-move.last.to_i][board.row.index(move.first)] == king_value
                return true
            end
        end
        false
    end

    def rescue_king?(opponent, last_position)
        all_possible_pices = []
        pices_moves = {}
        # get all the player pices
        king = nil
        @board.get_all_player_pices.each do |pice|
            
            if ["\u2654 ", "\u265A "].include?(pice.last)
                king = pice 
            else
                pices_moves[pice.last] = Array.new
                # check the player's pices that can kill the checkmate source
                @board.get_possible_moves(pice.first).each do |pos|
                    # deep copy of board object
                    @board.player == 'w' ? color = 'b' : color = 'w'
                    copy = Marshal.load( Marshal.dump(Board.new(color, @board.chess_board)) )
                    copy.move_pice(pice.first, pos)
                    # check if the king is still checked if we take this position 
                    pices_moves[pice.last].push(pos) if checkmate?(last_position, copy) == false || pos == last_position
                end
                all_possible_pices.push(pice) unless pices_moves[pice.last].empty?
            end
        end

        # adding king position without attacking the pice
        king_moves = @board.get_possible_moves(@board.get_king_position)
        all_possible_pices.push(king) unless king_moves.empty?
        
        # if we have no one to attack the pice 
        if all_possible_pices.empty?
            return false

        else
            puts "you need to rescue your king.."
            puts "What you will do:"
             # the opponent is computer
             # computer turn
            if opponent == "Computer" && @board.player == 'b'
                print_player_pices(all_possible_pices)
                input = rand(0..all_possible_pices.length-1)
                puts "Computer choice #{input + 1} "
                if king.nil? == false && all_possible_pices[input].last == king.last
                    puts "What is your next move then:"
                    print_player_possible_moves(king_moves)
                    input = rand(0..king_moves.length-1)
                    puts "Computer choice #{input + 1} "
                    @board.move_pice(king.first, king_moves[input])
                else
                    puts "What is your next move then:"
                    picked_pice_moves = pices_moves[all_possible_pices[input].last]
                    print_player_possible_moves(picked_pice_moves)
                    input = rand(0..picked_pice_moves.length-1)
                    puts "Computer choice #{input + 1} "
                    @board.move_pice(all_possible_pices[input].first, picked_pice_moves[input])
                end
                
            else

                print_player_pices(all_possible_pices)
                input = gets.chomp.to_i 
                if (1..all_possible_pices.length).to_a.include?(input)
                    # if the player choose to play the king
                    if all_possible_pices[input-1].last == king.last
                        puts "What is your next move then:"
                        print_player_possible_moves(king_moves)
                        input = gets.chomp.to_i
                        if (1..king_moves.length).to_a.include?(input)
                            @board.move_pice(king.first, king_moves[input-1])
                        else
                            puts "\u001b[91mPlease, enter one of the choices!!!"
                            puts "------------Try Again-----------\u001b[0m"
                            rescue_king?(opponent, last_position)
                        end
                    else
                        puts "What is your next move then:"
                        picked_pice_moves = pices_moves[all_possible_pices[input-1].last]
                        print_player_possible_moves(picked_pice_moves)
                        input = gets.chomp.to_i
                        if (1..picked_pice_moves.length).to_a.include?(input)
                            @board.move_pice(all_possible_pices[input-1].first, picked_pice_moves[input-1])
                        else
                            puts "\u001b[91mPlease, enter one of the choices!!!"
                            puts "------------Try Again-----------\u001b[0m"
                            rescue_king?(opponent, last_position)
                        end
                    end
                else
                    puts "\u001b[91mPlease, enter one of the choices!!!"
                    puts "------------Try Again-----------\u001b[0m"
                    rescue_king?(opponent, last_position)
                end
            end
        end 
        true    
    end

    # swap pawn when it reach the end of the enemy line
    def  promote_pawn(pos, computer)
        if @board.player == "w"
            pices_swap = ["\u2655 ", "\u2656 ", "\u2657 ", "\u2658 "]
        else
            pices_swap = ["\u265B ", "\u265C ", "\u265D ", "\u265E "]
        end

        puts "-----you can now promote your pawn--------"
        puts "choose what pice you want to promote to?"
        pices_swap.each_with_index { |pice, index| print "#{index+1}) #{pice}\t" }
        if computer 
            input = rand(0..pices_swap.length-1)
            puts "Computer choice #{input+1} "
            @board.chess_board[8-pos.last.to_i][@board.row.index(pos.first)] = pices_swap[input]
        else
            input = gets.chomp.to_i
            if (1..pices_swap.length).to_a.include?(input)
                @board.chess_board[8-pos.last.to_i][@board.row.index(pos.first)] = pices_swap[input-1]
            else
                puts "\u001b[91mPlease, enter one of the choices!!!"
                puts "------------Try Again-----------\u001b[0m"
                promote_pawn(pos, computer)
            end
        end
    end
end