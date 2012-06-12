class MockBrowser
  include HTTParty
  http_proxy Settings.proxy.host, Settings.proxy.port if Settings.proxy.enabled

  class << self
    alias_method :get_http, :get
  end

  # an interface to get local file as HTML uri.
  def self.get(target, options ={})
    if target.start_with?('http')
      self.get_http target,options
    else
      # in the case for our unit tests
      self.read_local_file target
    end
  end
  private
  def self.read_local_file file_path
    IO.read file_path
  end

end
