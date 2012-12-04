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

  context "failure responses" do
    let(:web) { 'http://example.com/Troll%20face.svg' }

    # fail once
    fail_once = {
      "400" => "Bad Request",
      "401" => "Unauthorized",
      "403" => "Forbidden",
      "404" => "Not Found",
      "405" => "Method Not Allowed",
      "501" => "Not Implemented"
    }
    fail_once.each do |code, msg|
      it "#{code}" do
        stub_request(:get, web).to_return(:status => [code, msg])
        expect { DiskCache.put(web) }.to raise_error(OpenURI::HTTPError)
        DiskCache.get(web).should be_nil
      end
    end

    # retry!
    retry_on_failure = {
      "408" => "Request Timeout",
      "409" => "Conflict",
      "410" => "Gone",
      "500" => "Internal Server Error",
      "502" => "Bad Gateway",
      "503" => "Service Unavailable",
      "504" => "Gateway Timeout"
    }
    retry_on_failure.each do |code, msg|
      it "#{code}" do
        stub_request(:get, web).to_return(:status => [code, msg])
        expect { DiskCache.put(web) }.to raise_error(OpenURI::HTTPError)
        DiskCache.get(web).should be_nil
      end
    end

    it "should retry on timeout" do
      stub_request(:get, web).to_timeout
      expect { DiskCache.put(web) }.to raise_error(Timeout::Error)
      DiskCache.get(web).should be_nil
    end

    it "should retry on SSL Error" do
      stub_request(:get, web).to_raise(OpenSSL::SSL::SSLError)
      expect { DiskCache.put(web) }.to raise_error(OpenSSL::SSL::SSLError)
      DiskCache.get(web).should be_nil
    end
  end
end
