require 'socket'
require 'cgi'
require 'pg'
require 'byebug'

PORT = 3000
socket = TCPServer.new('0.0.0.0', PORT)

puts "Listening to the port #{PORT}..."

# Database connection
db_connection = PG.connect(
  host: 'yataxdb',
  user: 'yatax',
  password: 'yatax',
  dbname: 'yatax',
)

loop do
  # Wait for a new TCP connection..."
  client = socket.accept

  # Request
  request = ''
  headers = {}
  body    = ''
  params  = {}
  cookies = {}

  request_verb = ''
  request_path = ''

  while line = client.gets
    break if line == "\r\n"

    # Extract Request verb and path
    if line.match(/HTTP\/.*?/)
      request_verb, request_path, _ = line.split
    end

    request += line

    # Request headers
    header_key, header_value = line.split(': ')
    headers[header_key] = header_value
  end

  puts request
  puts "\n"

  # Request body
  content_length = headers['Content-Length']
  body = client.read(content_length.to_i) if content_length

  # Extract params from body
  body_parts = body.split('&')
  params = body_parts
    .map { |part| part.split('=').map(&CGI.method(:unescape)) }
    .to_h

  # Request cookies
  if cookie = headers['Cookie']
    cookie_name, cookie_value = cookie.split('=')
    cookies[cookie_name] = CGI.unescape(cookie_value)
  end

  # Response
  response_headline = "HTTP/2.0"
  response_status   = 200
  response_headers  = { 'Content-Type' => 'text/html' }

  if request_verb == 'POST' && request_path == '/logout'
    response_status = 301

    response_headers['Set-Cookie'] = "email=; path=/; HttpOnly; Expires=Thu, 01 Jan 1970 00:00:00 GMT"
    response_headers['Location'] = "http://localhost:3000/"
  elsif request_verb == 'POST' && request_path == '/login'
    email = params['email']
    password = params['password']

    # Check user and password in the database
    query = %{
SELECT id FROM users
WHERE email = $1 AND password = crypt($2, password)
    }

    safe_query = db_connection.escape_string(query)
    result = db_connection.exec(safe_query, [email, password]).to_a.first

    if result
      response_status = 301

      response_headers['Set-Cookie'] = "email=#{email}; path=/; HttpOnly"
      response_headers['Location'] = "http://localhost:3000/"
    else
      # Incorrect Email/Password
      response_status = 401

      response_body = %{
<h1>Unauthorized</h1>
<a href="/">Home</a>
      }
    end
  elsif request_verb == 'GET' && request_path == '/'
    if email = cookies['email']
      response_body = %{
<h1>Hello, #{email}</h1>
<form action="/logout" method="POST">
  <input type="submit" value="Logout" />
</form>
      }
    else
      response_body = %{
<form action="/login" method="POST">
  <input type="text" placeholder="Email" name="email"/>
  <input type="password" placeholder="Password" name="password"/>
  <input type="submit" value="Login"/>
</form>
      }
    end
  else
    response_status = 404

    response_body = %{
<h1>Not Found</h1>
    }
  end

  response_headers_str =
    response_headers.reduce('') do |acc, (key, value)|
      acc += "#{key}: #{value}\r\n"; acc
    end

  response = "#{response_headline} #{response_status}\r\n#{response_headers_str}\r\n#{response_body}"

  client.puts(response.strip.gsub(/\n+/, "\n"))

  # Close connection
  client.close
end
