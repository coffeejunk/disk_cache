require 'spec_helper'

describe FileCache do
  let(:path) { 'spec/asset/Trollface.svg' }
  let(:file) { File.open(path, 'r') }

  context "storing and accessing" do
    it ".put" do
      FileCache.put(path)
      FileCache.get(path).should_not be_nil
    end

    it ".get" do
      FileCache.put(path)
      file_from_cache = FileCache.get(path)
      FileUtils.compare_file(file, file_from_cache).should be_true
    end

    it ".pget" do
      FileCache.del(path)
      file_from_cache = FileCache.pget(path)
      FileUtils.compare_file(file, file_from_cache).should be_true
    end
  end

  context "removing data" do
    before(:each) { FileCache.put(path) }

    it ".delete" do
      FileCache.del(path)
      FileCache.get(path).should be_nil
    end
  end
end
