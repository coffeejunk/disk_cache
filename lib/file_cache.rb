require 'file_cache/version'
require 'open-uri'
require 'digest/sha2'

module FileCache
  extend self

  # Public: save a file to the cache
  #
  # url - The URL to the file
  #
  # Example:
  #
  #   FileCache.put('http://example.com/test123.jpg')
  #   #=> nil
  #
  # Returns: nil
  def put(url)
    p = path(url)
    f = filename(url)
    return nil if File.exist?(p + f)

    FileUtils.mkdir_p p
    File.open(p + f, "wb") { |f| f << open(url).read }
    nil
  end

  # Public: get a file from the cache
  #
  # url - The URL to the file
  #
  # Examples:
  #
  #   FileCache.get('http://example.com/test123.jpg')
  #   # => #<File:9ae274d94c34542ddd1b64667c1d4e392211ff67>
  #
  #   FileCache.get('http://example.com/test123.jpg')
  #   # => nil
  #
  # Returns the File or nil
  def get(url)
    File.open(path(url) + filename(url), "rb")
  rescue Errno::ENOENT
    nil
  end

  # Public: get a file and save it to the cache if it isn't there already
  #
  # url - The URL to the file
  #
  # Examples:
  #
  #   FileCache.get('http://example.com/test123.jpg')
  #   # => #<File:9ae274d94c34542ddd1b64667c1d4e392211ff67>
  #
  # Returns a File
  def pget(url)
    put(url)
    get(url)
  end

  # Public: delete a file from the cache
  #
  # url - The URL to the file
  #
  # Example:
  #
  #   FileCache.del('http://example.com/test123.jpg')
  #   # => nil
  #
  # Returns nil
  def del(url)
    file = path(url) + filename(url)
    FileUtils.rm file, force: true
  end

  private

  # Internal: Hashes a given piece of data with SHA1
  #
  # datum - piece of data to be hashed
  #
  # Examples:
  #
  #   hasher('hi')
  #   # => "c22b5f9178342609428d6f51b2c5af4c0bde6a42"
  #
  # Returns String with hexdigest
  def hasher(datum)
    @hasher ||= Digest::SHA1.new
    @hasher.hexdigest(datum)
  end

  # Internal: Return the directory of the cache as a String
  def cache_dir
    Dir.pwd + '/cache/'
  end

  # Internal: Calculate a files path
  #
  # url - the URL of the file
  #
  # Example:
  #
  #   path('http://example.com/test123.jpg')
  #   # => "cache/9a/e2/"
  def path(url)
    hsh = hasher(url)
    dir = hsh[0..1] + '/'
    subdir = hsh[2..3] + '/'
    cache_dir + dir + subdir
  end

  # Internal: calculate the filename for a file
  #
  # url - the URL of the file
  #
  # Example:
  #
  #   path('http://example.com/test123.jpg')
  #   # => "74d94c34542ddd1b64667c1d4e392211ff67"
  def filename(url)
    hsh = hasher(url)
    hsh[4..-1]
  end
end
