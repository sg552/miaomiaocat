class CrawlerLoggerDecorator
  attr_accessor :logger
  def initialize(logger, crawler)
    @logger = logger
    @crawler = crawler
  end

  [:debug, :info, :warn, :error, :fatal].each do |level|
    define_method level do |content|
      @logger.send level, "(#{@crawler.source_website.name}) #{content}"
    end
  end

end
