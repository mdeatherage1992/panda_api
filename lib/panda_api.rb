require 'httparty'
require 'faraday_middleware'
require 'launchy'
require 'uri'
require 'pry'

class PandaDoc
  include HTTParty

  attr_accessor :key, :key_type

  def initialize(params)
    @key = params[:key]
    @key_type = params[:key_type]
  end

  # generic headers EXCEPT create doc from PDF
  def headers
    if @key_type == "bearer"
      {
        'Authorization': "Bearer #{@key}",
        "Content-Type": "application/json"
      }
    else
      {
        'Authorization': "API-Key #{@key}",
        "Content-Type": "application/json"
      }
    end
  end

  # key to make request is present
  def raise_if_non_authed
    raise 'No access key to make request' unless !@key.nil?
  end

  # show calls have corresponding ID
  def raise_if_no_id(params)
    raise 'No ID to make request' unless !params[:id].nil?
  end

  def document_status(params = nil)
    raise_if_non_authed
    raise_if_no_id(params)

    self.class.get("https://api.pandadoc.com/public/v1/documents/#{params[:id]}", headers: headers).parsed_response
  end

  def document_details(params = nil)
    raise_if_non_authed
    raise_if_no_id(params)

    self.class.get("https://api.pandadoc.com/public/v1/documents/#{params[:id]}/details", headers: headers).parsed_response
  end

  def list_documents(params = nil)
    raise_if_non_authed
    sanitized_params = params.nil? ? params : URI.encode_www_form(params)
    self.class.get("https://api.pandadoc.com/public/v1/documents?#{sanitized_params}", headers: headers).parsed_response
  end

  def download_document(params = nil)
    raise_if_non_authed
    raise_if_no_id(params)

    sanitized_params = params.nil? ? params : URI.encode_www_form(params)
    self.class.get("https://api.pandadoc.com/public/v1/documents/#{params[:id]}/download?#{sanitized_params}", headers: headers).parsed_response
  end

  def download_protected_document(params = nil)
    raise_if_non_authed
    raise_if_no_id(params)

    self.class.get("https://api.pandadoc.com/public/v1/documents/#{params[:id]}/download-protected", headers: headers).parsed_response
  end

  def list_templates(params = nil)
    raise_if_non_authed
    sanitized_params = params.nil? ? params : URI.encode_www_form(params)
    self.class.get("https://api.pandadoc.com/public/v1/templates?#{sanitized_params}", headers: headers).parsed_response
  end

  def template_details(params = nil)
    raise_if_non_authed
    raise_if_no_id(params)

    self.class.get("https://api.pandadoc.com/public/v1/templates/#{params[:id]}/details", headers: headers).parsed_response
  end

  def list_document_folders(params = nil)
    raise_if_non_authed
    sanitized_params = params.nil? ? params : URI.encode_www_form(params)
    self.class.get("https://api.pandadoc.com/public/v1/documents/folders?#{sanitized_params}", headers: headers).parsed_response
  end

  def list_template_folders(params = nil)
    raise_if_non_authed
    sanitized_params = params.nil? ? params : URI.encode_www_form(params)
    self.class.get("https://api.pandadoc.com/public/v1/templates/folders?#{sanitized_params}", headers: headers).parsed_response
  end

  # POST

  def create_document_from_pdf(params = nil)
    raise_if_non_authed
    # URI for Request
    url = URI.parse('https://api.pandadoc.com/public/v1/documents/')
    # Payload will have a file along with other form-data
    json =
    {
        "name": params[:name],
        "recipients": params[:recipients],
        "fields": params[:fields],
        "metadata": params[:metadata],
        "parse_form_fields": params[:parse_form_fields]
    }

    payload = {
      data: JSON.dump(json),
      file: Faraday::UploadIO.new(params[:file], "application/pdf")
    }
    # making request connection
    connection = Faraday.new(url) do |conn|
      conn.authorization "API-Key", @key

      # request is multipart
      conn.request     :multipart
      # url_encoded request
      conn.request     :url_encoded

      # expects json
      conn.response      :json, content_type: /\bjson$/
      conn.adapter       Faraday.default_adapter
    end
    # make request
    connection.post(url, payload).body
  end

  def create_document_from_template(params = nil)
    raise_if_non_authed

    self.class.post('https://api.pandadoc.com/public/v1/documents/', body: JSON.dump(params), headers: headers).parsed_response
  end

  def send_document(params = nil)
    raise_if_non_authed

    self.class.post("https://api.pandadoc.com/public/v1/documents/#{params[:id]}/send", body: JSON.dump(params), headers: headers).parsed_response
  end

  def create_document_link(params = nil)
    raise_if_non_authed

    self.class.post("https://api.pandadoc.com/public/v1/documents/#{params[:id]}/session", body: JSON.dump(params), headers: headers).parsed_response
  end

  def create_document_folder(params = nil)
    raise_if_non_authed
    self.class.post('https://api.pandadoc.com/public/v1/documents/folders', headers: headers, body: JSON.dump(params)).parsed_response
  end

  def create_template_folder(params = nil)
    raise_if_non_authed
    self.class.post('https://api.pandadoc.com/public/v1/templates/folders', headers: headers, body: JSON.dump(params)).parsed_response
  end

  def get_code(params = nil)
    first = "https://app.pandadoc.com/oauth2/authorize?client_id=#{params[:client_id]}&redirect_uri=#{params[:redirect_uri]}&scope=read+write&response_type=code"
    Launchy.open(first)
    puts "enter the code located on your redirect URI browser instance: "
    code = STDIN.gets
    params[:code] = code
    self.get_oauth_access_token(params)
  end

  def refresh_access_token(params = nil)
    raise_if_non_authed
    # required => client, client_secret, redirect
    parsed_params = {
      "grant_type": "refresh_token",
      "client_id": @client_id || params[:client_id],
      "client_secret": @client_secret || params[:client_secret],
      "refresh_token": params[:refresh_token],
      "code": params[:code],
      "scope": params[:scope] || 'read+write'
    }

    missing_keys = parsed_params.keys.select { |p| parsed_params[p.to_sym].nil? }

    raise "Please Provide #{missing_keys.join(', ')} to make request" if missing_keys.length > 0
    res = self.class.post("https://api.pandadoc.com/oauth2/access_token", body: URI.encode_www_form(parsed_params), headers: {"Accept": "application/json"}).parsed_response

    @key = res["access_token"]
    @key_type = "bearer"

    res
  end

  def delete_document(params = nil)
    raise_if_no_id(params)
    self.class.delete("https://api.pandadoc.com/public/v1/documents/#{params[:id]}", headers: headers).parsed_response
  end

  def delete_template(params = nil)
    raise_if_no_id(params)
    self.class.delete("https://api.pandadoc.com/public/v1/templates/#{params[:id]}", headers: headers).parsed_response
  end

  def update_document_folder(params = nil)
    raise_if_no_id(params)
    self.class.put("https://api.pandadoc.com/public/v1/documents/folders/#{params[:id]}", headers: headers, body: JSON.dump(params)).parsed_response
  end

  def update_template_folder(params = nil)
    raise_if_no_id(params)
    self.class.put("https://api.pandadoc.com/public/v1/templates/folders/#{params[:id]}", headers: headers, body: JSON.dump(params)).parsed_response
  end

  protected

  def get_oauth_access_token(params = nil)
    # required => client, client_secret, redirect
    parsed_params = {
      "grant_type": "authorization_code",
      "client_id": @client_id || params[:client_id],
      "client_secret": @client_secret || params[:client_secret],
      "code": params[:code],
      "scope": 'read+write',
      "redirect_uri": @redirect_uri || params[:redirect_uri]
    }

    missing_keys = parsed_params.keys.select { |p| parsed_params[p.to_sym].nil? }

    raise "Please Provide #{missing_keys.join(', ')} to make request" if missing_keys.length > 0

    res = self.class.post("https://api.pandadoc.com/oauth2/access_token", body: URI.encode_www_form(parsed_params), headers: {"Accept": "application/json"}).parsed_response

    @key = res["access_token"]
    @key_type = "bearer"

    res
  end
end
