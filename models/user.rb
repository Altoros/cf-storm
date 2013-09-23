class User  < Ohm::Model
  extend Forwardable

  def_delegators :client, :login, :spaces, :domains, :route,
                 :domains_by_name

  attribute :email
  attribute :token
  attribute :refresh_token

  index :email

  def initialize(*args)
    @@_clients ||= {}
    super
  end

  def self.clear_client_cache!
    @@_clients = {}
  end

  def self.clients
    @@_clients
  end

  def current_organization
    client.current_organization || client.organizations.first
  end

  def create_space!(name)
    space = client.space
    space.organization = current_organization
    space.name         = name
    space.create!
  end

  def self.authenticate email, password
    user   = User.find(:email => email).first
    user ||= User.new :email => email

    begin
      token = user.login(:username => email, :password => password)
    rescue CFoundry::Denied
      return nil
    end

    user.cftoken = token
    user.save
  end

  def client
    if @@_clients[self.email]
      refresh_tokens @@_clients[self.email].token
      return @@_clients[self.email] unless  @@_clients[self.email].nil?
    end
    @@_clients[self.email] = User.default_client.get User.api_url, cftoken
    refresh_tokens @@_clients[self.email].token
    return @@_clients[self.email]
  end

  def refresh_tokens new_token
    unless new_token.auth_header == self.token
      self.cftoken = new_token
      self.save
    end
  end

  def cftoken
    CFoundry::AuthToken.new token, refresh_token
  end

  def cftoken=(cftoken)
    self.token         = cftoken.auth_header
    self.refresh_token = cftoken.refresh_token
  end

  def self.default_client
    @default_client || CFoundry::Client
  end

  def self.api_url
    Settings::API_URL
  end

  def self.default_client=(client)
    @default_client = client
  end

  def self.with_default_client(client_class)
    prev_default_client = User.default_client

    User.default_client = client_class
    yield
    @default_client = prev_default_client
  end

  require 'digest/md5'
  def avatar_file
    "#{Digest::MD5.hexdigest(self.email)}.png"
  end

end
