require 'socket'
require 'cgi'

PORT = 3000
socket = TCPServer.new('0.0.0.0', PORT)

puts "Listening to the port #{PORT}..."

loop do
  # Wait for a new TCP connection..."
  client = socket.accept

  # Request
  request = ''
  headers = {}
  body    = ''
  params  = {}
  cookies = {}

  while line = client.gets
    break if line == "\r\n"
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

  cookies['email'] ||= params['email']

  # Response
  response = %{
HTTP/2.0 200\r\n
Content-Type: text/html\r\n
Set-Cookie: email=#{cookies['email']}; HttpOnly\r\n
\r\n
<form action="/" method="POST">
  <input type="text" placeholder="Email" name="email"/>
  <input type="password" placeholder="Password" name="password"/>
  <input type="submit" value="Login"/>
</form>
}

  client.puts(response.strip.gsub(/\n+/, "\n"))

  # Close connection
  client.close
end
