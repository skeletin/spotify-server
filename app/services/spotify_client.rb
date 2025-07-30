require "securerandom"
require 'net/http'
require 'uri'
require 'json'
require 'base64'

class SpotifyClient
  CLIENT_ID = "601456a8e306456c81008f8264402127"
  CLIENT_SECRET = "fa386f9bee304ea285de59487d407d60"
  REDIRECT_URI = "http://[::1]:5173/callback"
  STATE_KEY = "spotify_auth_state"

  def login(cookies)
    state = generate_random_string(16)
    scope = "user-read-private user-read-email"
    cookies[STATE_KEY] = {
      value: state,
      httponly: true,
      same_site: :lax,
    }
    query_params = URI.encode_www_form({
      response_type: "code",
      client_id: CLIENT_ID,
      scope: scope,
      redirect_uri: REDIRECT_URI,
      state: state,
    })

    return {
             redirect_to: "https://accounts.spotify.com/authorize?#{query_params}",
             cookies: cookies,
           }
  end

  def callback(params)
    code = params[:code]

    uri = URI("https://accounts.spotify.com/api/token")

    # Prepare POST form data
    form_data = URI.encode_www_form(
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: REDIRECT_URI
    )

    # Prepare Authorization header
    auth_header = "Basic " + Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")

    # Create and configure HTTP POST request
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Authorization"] = auth_header
    request.body = form_data

    # Make the request
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse JSON response
    JSON.parse(response.body).deep_transform_keys! { |key| key.camelize(:lower) }
  end

  
  private
  def generate_random_string(length)
    SecureRandom.hex(60)[0, length]
  end
end
