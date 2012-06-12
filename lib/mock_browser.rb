class MockBrowser
  include HTTParty
  http_proxy Settings.proxy.host, Settings.proxy.port if Settings.proxy.enabled

  class << self
    alias_method :read_http, :get
  end

  # an interface to get local file as HTML uri.
  # examples:
  #   self.get('file://spec/fixtures/page1_the_simplest.html')
  #   self.get('http://www.baidu.com')
  def self.get(target, options ={})
    if target.start_with?('file://')
      # in the case for our unit tests
      self.read_local_file target.gsub('file://', '')
    else
      self.read_http(target,options).body
    end
  end
  private
  def self.read_local_file file_path
    IO.read file_path
  end

end
