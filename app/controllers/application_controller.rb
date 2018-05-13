class ApplicationController < ActionController::API
  private

  def authenticate
    id_token = Auth.extract_id_token(request.headers)
    unless id_token
      response.headers['WWW-Authenticate'] = 'Bearer realm="token_required"'
      return head(:unauthorized)
    end
    id_string = Auth.verify_id_token(id_token)
    unless id_string
      response.headers['WWW-Authenticate'] = 'Bearer error="invalid_token"'
      return head(:unauthorized)
    end
    @auth_user = User.find_or_initialize_by(id_string: id_string)
  end
end
