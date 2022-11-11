require 'json'
require 'rack'

$app ||= Rack::Builder.parse_file("config.ru").first

def handler(event:, context:)
  headers = event.fetch('headers', {})

  env = {
    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => headers.fetch('CloudFront-Forwarded-Proto') { headers.fetch('X-Forwarded-Proto', 'https') },
    'rack.errors' => $stderr,
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => headers.fetch('Host', 'localhost'),
    'SERVER_PORT' => headers.fetch('X-Forwarded-Port', 443).to_s,
    'REQUEST_METHOD' => event.dig('requestContext', 'http', 'method'),
    'PATH_INFO' => event.dig('rawPath'),
    'QUERY_STRING' => event['rawQueryString'],
    'HTTP_AUTHORIZATION' => headers.dig('authorization')
  }

  unless event['headers'].nil?
    event['headers'].each do |key, value|
      formatted_key = key.upcase.gsub("-", "_")

      env["HTTP_#{formatted_key}"] = value
    end
  end

  status, headers, body = $app.call(env)

  body_content = ""
  body.each do |item|
    body_content += item.to_s
  end

  response = {
    "statusCode" => status,
    "headers" => headers,
    "body" => body_content.force_encoding("UTF-8")
  }

  response
end
