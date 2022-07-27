# S:save, U:uplode, D:delete
module FileSUD

     # ask the player to save the game
     def save_game(chess_board, color, opponent, last_position)
        puts "*******************************"
        puts "Do you want to save your game? 1)Yes 2)No"
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                # create a new yaml file to write data on it
                saved_file = File.open("saved_game.yaml","w")
                
                # write the data on the file in YAML shap
                saved_file.puts YAML.dump ({
                    :chess_board => chess_board,
                    :color => color,
                    :opponent => opponent,
                    :last_position => last_position,
                  })

                puts "Your game have been saved..."
                saved_file.close
                
            # player do not want to save the game
            else
                puts "Ok, Lets continue then..."
            end
        else
            puts "\u001b[91mPlease Enter 1 or 2!!!\u001b[0m"
            save_game(chess_board, color, opponent, last_position)
        end
    end

     # ask the player to uplode the previous game or not
     def uplode_saved_game?
        puts "Do you want to..." 
        puts "1)Continue your previous game."
        puts "2)Start new game."
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                return true
            end
        else
            puts "\u001b[91mPlease Enter 1 or 2!!!\u001b[0m"
            uplode_saved_game?
        end
        false
    end

    # ask for delete the file after winning or losing 
    def delete_saved_file
        puts "Do you want to delete saved game? 1)Yes 2)No"
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                File.delete("saved_game.yaml")
            end
        else
            puts "Please Enter 1 or 2!!!"
            delete_saved_file()
        end
    end
end