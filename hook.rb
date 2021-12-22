# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'logger'

post '/payload' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)

  push = JSON.parse(payload_body)
  "I got some JSON: #{push.inspect}"
end

def verify_signature(payload_body)
  signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['SECRET_TOKEN'], payload_body)
  compared = Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])

  logger = Logger.new(STDOUT)
  logger.debug(request.env['HTTP_X_HUB_SIGNATURE_256'])
  logger.debug(ENV['SECRET_TOKEN'])

  return halt 500, "Signatures didn't match!" unless compared
end
