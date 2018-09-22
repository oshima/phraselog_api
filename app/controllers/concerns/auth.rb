# References:
# https://firebase.google.com/docs/auth/admin/verify-id-tokens
# https://github.com/soulfly/firebase-id-tokens-verifier

require 'digest/sha2'
require 'net/http'

module Auth
  FIREBASE_PROJECT_ID = Rails.application.config.firebase_project_id
  JWT_PUBLIC_KEYS_LOCATION_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
  JWT_PUBLIC_KEYS_CACHE_KEY = 'JWT_PUBLIC_KEYS'
  JWT_VERIFY_OPTIONS = {
    algorithm: 'RS256',
    aud: FIREBASE_PROJECT_ID,
    iss: "https://securetoken.google.com/#{FIREBASE_PROJECT_ID}",
    verify_expiration: true,
    verify_iat: true,
    verify_aud: true,
    verify_iss: true
  }

  class << self
    def extract_id_token(request_headers)
      unless request_headers['Authorization']
        Rails.logger.info("Request headers have no 'Authorization'")
        return nil
      end
      scheme, id_token = request_headers['Authorization'].split
      unless scheme == 'Bearer' && id_token
        Rails.logger.info("Request headers have invalid 'Authorization'")
        return nil
      end
      id_token
    end

    def verify_id_token(id_token)
      # Decode (don't verify)
      payload, headers = JWT.decode(id_token, nil, false)

      # Specify the public key corresponding to the private key used for signature
      public_key = fetch_public_keys[headers['kid']]
      if public_key.blank?
        Rails.logger.info("JWT headers have no or invalid 'kid'")
        return nil
      end

      # Decode again to verify
      payload, headers = JWT.decode(
        id_token,
        OpenSSL::X509::Certificate.new(public_key).public_key,
        true,
        JWT_VERIFY_OPTIONS
      )

      # Extract user id (id_string)
      id_string = payload['sub']
      if id_string.blank?
        Rails.logger.info("JWT payload has no or invalid 'sub'")
        return nil
      end
      id_string
    rescue JWT::DecodeError => e
      Rails.logger.info(e)
      return nil
    end

    private

    def fetch_public_keys
      public_keys = Rails.cache.read(JWT_PUBLIC_KEYS_CACHE_KEY)
      return public_keys if public_keys

      uri = URI.parse(JWT_PUBLIC_KEYS_LOCATION_URL)
      https = Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = true }
      req = Net::HTTP::Get.new(uri.path)

      res = https.request(req)
      if res.code != '200'
        raise 'Response for fetching JWT public keys is not 200 OK'
      end

      public_keys = JSON.parse(res.body)
      max_age = res['cache-control'][/max-age=(\d+?),/m, 1]
      Rails.cache.write(JWT_PUBLIC_KEYS_CACHE_KEY, public_keys, expires_in: max_age.to_i)

      public_keys
    end
  end
end
