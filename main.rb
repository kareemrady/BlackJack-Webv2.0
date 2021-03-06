require 'rubygems'
require 'sinatra'

set :sessions, true


helpers do
	def show_card(card) # ["H","4"]
		suit = case card[0]
		when "H" then "hearts"
		when "D" then "diamonds"
		when "S" then "spades"
		when "C" then "clubs"
		end
		value = card[1]
		if ["A", "K", "Q", "J"].include?(value)
			value = case card[1]
			when "A" then "ace"
			when "J" then "jack"
			when "Q" then "queen"
			when "K" then "king"
			end
		end
		"<img src ='/images/cards/#{suit}_#{value}.jpg' class='img_cards'/>"
end

def calc_total(cards)  #calc_total(session[:player_cards])
	#where session[:cards] = [["H", "4"], ["C", "3"]]
	total = 0
		values = cards.map {|card| card[1]}
			values.each do |value|
			if value == "A"
				total += 11
			else
				value.to_i == 0 ? total += 10 : total += value.to_i
				end
			end
		total
		# correct for Aces
		values.select {|card| card == "A"}.count.times do
			total -= 10 if total > 21
		end
		total

end

def player_busted?
if calc_total(session[:player_cards]) > 21
	session[:player_pot] -= session[:player_bet]
	@display_welcome_message = false
	@loser = "Sorry #{session[:player_name].capitalize} you have busted!!!, you now have $#{session[:player_pot]}"
	@show_hit_stay = false
	@show_cards_dealer = true
	@play_again = true
	@show_dealer_score = true
	
end
end

def dealer_busted?
	if calc_total(session[:dealer_cards]) > 21
		session[:player_pot] += session[:player_bet]
		@display_welcome_message = false
	@winner = "Congratulations #{session[:player_name].capitalize} Dealer busted!!!, you now have $#{session[:player_pot]}"
	@show_hit_stay = false
	@show_cards_dealer = true
	@show_dealer_score = true
	@play_again = true
	
	
	
end
end

def dealer_blackjack?
if calc_total(session[:dealer_cards]) == 21
	session[:player_pot] -= session[:player_bet]
	@display_welcome_message = false
	@loser = "Sorry #{session[:player_name].capitalize}, Dealer hit blackjack!!!, you now have $#{session[:player_pot]}"
	@show_hit_stay = false
	@show_cards_dealer = true
	@show_dealer_score = true
	@play_again = true
	
end
end
def player_blackjack?
if calc_total(session[:player_cards]) == 21
	session[:player_pot] += session[:player_bet]
	@display_welcome_message = false
	@winner = "Congratulations #{session[:player_name].capitalize}, you hit blackjack!!!, you now have $#{session[:player_pot]}"
	@show_hit_stay = false
	@show_cards_dealer = true
	@show_dealer_score = true
	@play_again = true
	
		
end
end
def draw?
if calc_total(session[:player_cards]) == calc_total(session[:dealer_cards])
	session[:player_pot]
	@loser = "It's a Draw!!!, you now have $#{session[:player_pot]}"
	@display_welcome_message = false
	@show_hit_stay = false
	@show_cards_dealer = true
	@show_dealer_score = true
	@play_again = true
		
end
end

def who_won?
if (calc_total(session[:player_cards]) - 21).abs  < (calc_total(session[:dealer_cards]) - 21).abs 
	session[:player_pot] += session[:player_bet]
	@winner = "Congratulations #{session[:player_name].capitalize}, you win!!!, you now have $#{session[:player_pot]}"
	@display_welcome_message = false
	@show_hit_stay = false
	@show_cards_dealer = true
	@show_dealer_score = true
	@play_again = true

	
else 
	session[:player_pot] -= session[:player_bet]
	@loser = "Sorry #{session[:player_name].capitalize}, Dealer wins!!!, you now have $#{session[:player_pot]}"
	@display_welcome_message = false
	@show_hit_stay = false
	@show_dealer_score = true
	@show_cards_dealer = true
	@play_again = true
	

end
end

def game_over?
if session[:player_pot] == 0
	redirect '/game_over'
end
end

end

before do
	@display_welcome_message = true
	@show_hit_stay = true
	@show_cards_dealer = false
	@show_dealer_hit = false
	@show_dealer_score = false
	@play_again = false
	
end

 
 get "/" do
 	
 	if session[:player_name]
 		redirect '/game'
 	else
	redirect "/new_player"
	end
end
	
get "/new_player" do
	
	session[:player_pot] = 500
	erb :new_player
end

post "/new_player" do
	session[:player_name] = params[:player_name]
	if params[:player_name].empty?
		@error = "Name field cannot be blank"
		halt erb(:new_player)
	else
		
 redirect '/bet'
	
end
end

get '/bet' do
	
	erb :bet
end

post '/bet' do
	
	if params[:player_bet].to_i.nil? || params[:player_bet].to_i == 0
		@error = "Your bet cannot be left blank & cannot be Zero"
		halt erb(:bet)
	elsif params[:player_bet].to_i > session[:player_pot]
		@error = "Your bet cannot be greater than #{session[:player_pot]}"
		halt erb(:bet)
	else 
		session[:player_bet] = params[:player_bet].to_i
		redirect '/game'

end
end

get '/game' do
	session[:player_cards] = []
	session[:dealer_cards] = []
	session[:player_score] = 0
	session[:dealer_score] = 0
	suit = ["H", "C", "D", "S"]
	value = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10","K", "Q", "J"]
	session[:deck] = suit.product(value).shuffle!
	# initial round of cards
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_score] = calc_total(session[:player_cards])
	session[:dealer_score] = calc_total(session[:dealer_cards])
	if player_busted?
	elsif 
		player_blackjack?
	elsif 
		dealer_busted?
	else 
		dealer_blackjack?
	end
	game_over?

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	if player_busted?
	else
		player_blackjack?
	end
		game_over?
	erb :game, layout: false
end

post '/game/player/stay' do
	session[:player_cards]
	@success = "You Chose to Stay"
	@show_hit_stay = false
	redirect '/game/dealer'
erb :game, layout: false
end

# dealer's turn

get '/game/dealer' do
	@show_dealer_score = true
	@show_cards_dealer = true
@show_hit_stay = false
@show_dealer_hit = true
if dealer_blackjack?
else
	dealer_busted?
end
if calc_total(session[:dealer_cards]) >= 17
	redirect '/game/compare'
else
	@show_dealer_hit = true
	redirect '/game/dealer/hit'
	game_over?
end
end


get '/game/dealer/hit' do
	@show_dealer_score = true
	@show_cards_dealer = true
	@show_hit_stay = false
	@show_dealer_hit = true
	erb :game, layout: false
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect '/game/dealer'
end

get '/game/compare' do
	
	if draw?
	else
	who_won?
end
game_over?
	erb :game, layout: false
end

get '/game_over' do

	erb :game_over

end

get '/about' do

	erb :about

end

get '/contact' do
	erb :contact
end