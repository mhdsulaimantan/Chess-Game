require 'yaml'
require './lib/board.rb'
require './lib/file_sud.rb'
require './lib/rules.rb'

class Game

    include FileSUD
    include Rules

    @@last_position = nil

    def initialize
        puts "<--------------------------- CHESS --------------------------->"
        puts "Welcome, This is a simple chess game built using ruby."
        @board = Board.new('w')
        start()
    end

    private
    def start
        # check if there is a saved game before, also if the player approved to uplode the recent game
        if File.exist?("saved_game.yaml") && uplode_saved_game?
            puts "Loading....."
            game_data = YAML.load_file('saved_game.yaml')
            # fetch data from the saved game file
            chess_board = game_data[:chess_board]
            color = game_data[:color]
            opponent = game_data[:opponent]
            @@last_position = game_data[:last_position]
            puts "The data have been loaded, Lets start...."
            puts "your opponent is #{opponent}"
            new_game(opponent, color, chess_board)
        else
            puts "Ok, lets start new game..."
            puts "Please, choose your opponent:"
            puts "1) Computer"
            puts "2) Player 2"
            input = gets.chomp
            if input == "1"
                opponent = "Computer"
            elsif input == "2"
                opponent = "Player 2"
            else
                puts "Please, choose the right option!!!"
                start() 
            end

            puts "you picked #{opponent} as your opponent, lets start the game...."
            new_game(opponent)
        end
    end

    def new_game(opponent, color = @board.player ,chess_board = @board.chess_board)
        win = false
        if opponent == "Computer"
            computer(chess_board, color)

        else
            player(chess_board, color)
        end
        # ask the player to delete the saved file
        delete_saved_file if File.exist?("saved_game.yaml")
    end

    def computer(chess_board, color)
        win = false
        until win
            # save your progress
            save_game(chess_board, color, "Computer", @@last_position)
            if color == 'w'
                puts "\u001b[46mPlayer 1's turn...\u001b[0m"
                if checkmate?(@@last_position)
                    puts "\u001b[41m CheckMate \u001b[0m"
                    @board = Board.new(color, chess_board)
                    win = true unless rescue_king?("Computer", @@last_position)
                else 
                    @board = Board.new(color, chess_board)
                    # no more move to do
                    if @board.get_all_player_pices.empty?
                        puts "\u001b[41mNo more moves the player can do!!!\u001b[0m"
                        win = true
                    else
                        @board.print_board
                        # player choose a pice to play
                        # player picked right choose -> next player
                        puts "choose the pice that you want to play with:"
                        choose_pice()
                    end
                end
            else
                puts "\u001b[46mComputer's turn...\u001b[0m"
                if checkmate?(@@last_position)
                    puts "\u001b[41m CheckMate \u001b[0m"
                    @board = Board.new(color, chess_board)
                    win = true unless rescue_king?("Computer", @@last_position)
                           
                else 
                    @board = Board.new(color, chess_board)
                  
                    # no more move to do
                    if @board.get_all_player_pices.empty?
                        puts "\u001b[41mNo more moves the computer can do!!!\u001b[0m"
                        win = true
                    else
                        @board.print_board
                        # player choose a pice to play
                        # player picked right choose -> next player
                        puts "Computer will choose randomly the pice that it want to play with:"
                        choose_pice(true)
                    end
                end
            end

            # changing player for the next round
            color == 'w' ? color = 'b' : color = 'w'
        end
        puts "\u001b[42m #{color == 'w' ? "Player 1 Won :)" : "Computer WON :("} \u001b[0m"
    end

    def player(chess_board, color)
        win = false
        until win
            # save your progress
            save_game(chess_board, color, "Player 2", @@last_position)

            puts "\u001b[46mPlayer #{color == 'w' ? 1 : 2}'s turn...\u001b[0m"
            if checkmate?(@@last_position)
                puts "\u001b[41m CheckMate \u001b[0m"
                @board = Board.new(color, chess_board)
                win = true unless rescue_king?("Player 2", @@last_position)
            
            else
                @board = Board.new(color, chess_board)
                # no more move the player can do
                if @board.get_all_player_pices.empty?
                    puts "\u001b[41mNo more moves the player #{color == 'w' ? 1 : 2} can do!!!\u001b[0m"
                    win = true
                else
                    @board.print_board
                    # player choose a pice to play
                    # player picked right choose -> next player
                    puts "choose the pice that you want to play with:"
                    choose_pice()
                end
            end
            # changing player for the next round
            color == 'w' ? color = 'b' : color = 'w'
        end
        puts "\u001b[42m #{color == 'w' ? "Player 1 Won :)" : "Player 2 WON :)"} \u001b[0m"
    end

    def choose_pice(computer = false)
        all_pices = @board.get_all_player_pices
        # print player pices
        print_player_pices(all_pices)
        # player choose the pice to play with
        # computer is playing
        if computer
            input = rand(0..all_pices.length-1) 
            puts "Computer took the #{input+1} choice." 
            return choose_move(all_pices[input].first, 
            @board.get_possible_moves(all_pices[input].first), 
            computer)
        end

        # player is playing
        input = gets.chomp.to_i
        if (1..all_pices.length).to_a.include?(input)
            choose_move(all_pices[input-1].first, 
            @board.get_possible_moves(all_pices[input-1].first), 
            computer)
        else
            puts "\u001b[91mPlease, enter one of the choices!!!"
            puts "------------Try Again-----------\u001b[0m"
            choose_pice(computer)
        end
    end

   
    def choose_move(pos, possible_moves, computer)
        # print board with possible moves
        @board.print_board(pos)
        # player pick move
        if computer
            puts "Computer will choose where it wants to move:"
            print_player_possible_moves(possible_moves)
            input = rand(0..possible_moves.length-1)
            puts "Computer took the #{input+1} choice."
            @board.move_pice(pos, possible_moves[input])
            @@last_position = possible_moves[input]
        
        else
            # print all possible moves
            puts "choose where you want to move:"
            print_player_possible_moves(possible_moves)
            input = gets.chomp.to_i
            if (1..possible_moves.length).to_a.include?(input)
                # move to the choosed position
                @board.move_pice(pos, possible_moves[input-1])
                @@last_position = possible_moves[input-1]
            else
                puts "\u001b[91m Please, enter one of the choices!!!"
                puts "------------Try Again----------- \u001b[0m"
                choose_move(pos, possible_moves, computer)
            end
        end
        
        # check if the pice is pawn and at the end of the board
        pos = @@last_position.split("")
        tmp = @board.chess_board[8-pos.last.to_i][@board.row.index(pos.first)]
        if tmp == "♙ " && pos.last.to_i == 1
            promote_pawn(pos, computer)
        elsif tmp == "♟ " && pos.last.to_i == 8
            promote_pawn(pos, computer)
        end
    end

    def print_player_pices(all_pices)
        all_pices.each_with_index do |pice, index|
            print "#{index+1}) #{pice.first} -> #{pice.last}\t"
            puts if index%3 == 0
        end
    end

    def print_player_possible_moves(moves)
        moves.each_with_index do |move, index| 
            print "#{index+1}) #{move}\t"
            puts if index%3 == 0
        end
    end

end

Game.new()