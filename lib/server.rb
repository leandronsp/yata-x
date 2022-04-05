require 'socket'

PORT = 3000
socket = TCPServer.new('0.0.0.0', PORT)

puts "Listening to the port #{PORT}..."

loop do
  # Wait for a new TCP connection..."
  client = socket.accept

  # Request
  request = ''

  while line = client.gets
    break if line == "\r\n"
    request += line
  end

  puts request
  puts "\n"

  # Response
  response = """
  HTTP/2.0 200\r\n
  \r\n
  \r\n
  <h1>Hello</h1>
  """

  client.puts(response)

  # Close connection
  client.close
end
