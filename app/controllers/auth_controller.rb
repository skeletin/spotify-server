class AuthController < ApplicationController
  def initialize(spotify_client: SpotifyClient.new )
    @spotify_client = spotify_client
  end
  
  def login 
    render json: @spotify_client.login(cookies)
  end

  def callback
    render json: @spotify_client.callback(params)
  end
end
