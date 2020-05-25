require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << [('A'..'Z').to_a.sample] }
  end

  def score
    @letters_availables = params[:letters_availables]
    @word = params[:score]
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @game_result = run_game(@word, @letters_availables, @start_time, @end_time)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "Congratulation, #{attempt} is a valid English word!"]
      else
        [0, "Sorry but #{attempt} does not seem to be an English word..."]
      end
    else
      [0, "Sorry but #{attempt} can't be built out of #{grid}"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
