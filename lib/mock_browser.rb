class MockBrowser
  include HTTParty
  http_proxy "wwwgate0-ch.mot.com", 1080
end
