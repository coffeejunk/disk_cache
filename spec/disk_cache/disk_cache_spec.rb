require 'spec_helper'

describe DiskCache do
  let(:path) { 'spec/asset/Trollface.svg' }

  before(:each) { DiskCache.clear! }

  context "storing and accessing" do
    it ".put" do
      DiskCache.put(path)
      DiskCache.get(path).should_not be_nil
    end

    it ".get" do
      DiskCache.put(path)
      file_from_cache = DiskCache.get(path)
      FileUtils.compare_file(path, file_from_cache).should be_true
    end

    it ".pget" do
      DiskCache.del(path)
      file_from_cache = DiskCache.pget(path)
      FileUtils.compare_file(path, file_from_cache).should be_true
    end

    it ".filepath" do
      DiskCache.put(path)
      DiskCache.filepath(path).should include(
        'cache/fb/2b/228b717ea0a569bc7d12187ff55e5e3a0180')
    end
  end

  context "removing data" do
    before(:each) { DiskCache.put(path) }

    it ".delete" do
      DiskCache.del(path)
      DiskCache.get(path).should be_nil
    end

    it ".clear" do
      DiskCache.clear!
      DiskCache.get(path).should be_nil
    end
  end

  context "sanity" do
    let(:web) { 'http://example.com/Troll face.svg' }
    let(:web_correct) { 'http://example.com/Troll%20face.svg' }

    before(:each) do
      stub_request(:get, "http://example.com/Troll face.svg").
        to_return(body: File.read(path))

      stub_request(:get, "http://example.com/Troll%20face.svg").
        to_return(body: File.read(path))
    end

    it "should handle urls with spaces" do
      DiskCache.put(web)
      file_from_cache = DiskCache.get(web)
      FileUtils.compare_file(path, file_from_cache).should be_true
    end

    it "should handle urls with escaped spaces" do
      DiskCache.put(web_correct)
      file_from_cache = DiskCache.get(web_correct)
      FileUtils.compare_file(path, file_from_cache).should be_true
    end
  end
end
