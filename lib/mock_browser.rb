class MockBrowser
  include HTTParty
  http_proxy Settings.proxy.host, Settings.proxy.port if Settings.proxy.enabled
end
