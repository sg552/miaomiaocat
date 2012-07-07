require 'spec_helper'

describe SourceWebsite do
  before  do
    @crawler = create(:crawler)
    @source_website = @crawler.source_website
    @max_records_in_a_test_page = 10
  end
  it "fixtures should be saved " do
    SourceWebsite.all.size.should > 0
  end
end
