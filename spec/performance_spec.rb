require_relative "spec_helper"

describe Main do
  it "использование памяти не превышает заданный лимит" do
    described_class.new.call
    expect((`ps -o rss= -p #{Process.pid}`.to_i / 1024)).to be < 70
  end
end
