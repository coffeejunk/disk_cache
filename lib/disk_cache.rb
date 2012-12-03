require 'disk_cache/version'
require 'open-uri'
require 'digest/sha1'
require 'fileutils'

module DiskCache
  extend self

  # Public: save a file to the cache
  #
  # url - The URL to the file
  #
  # Example:
  #
  #   DiskCache.put('http://example.com/test123.jpg')
  #   #=> nil
  #
  # Returns: nil
  def put(url)
    file = filepath(url)
    return nil if File.exist?(file)

    FileUtils.mkdir_p path(url)
    File.open(file, "wb") { |f| f << open(escape(url)).read }
    nil
  end

  # Public: get a file from the cache
  #
  # url - The URL to the file
  #
  # Examples:
  #
  #   DiskCache.get('http://example.com/test123.jpg')
  #   # => #<File:9ae274d94c34542ddd1b64667c1d4e392211ff67>
  #
  #   DiskCache.get('http://example.com/test123.jpg')
  #   # => nil
  #
  # Returns the File or nil
  def get(url)
    File.open(filepath(url), "rb")
  rescue Errno::ENOENT
    nil
  end

  # Public: get a file and save it to the cache if it isn't there already
  #
  # url - The URL to the file
  #
  # Examples:
  #
  #   DiskCache.get('http://example.com/test123.jpg')
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
  #   DiskCache.del('http://example.com/test123.jpg')
  #   # => nil
  #
  # Returns nil
  def del(url)
    FileUtils.rm filepath(url), force: true
  end

  # Public: calculate the path/filename of a file's URL
  #
  # url - the URL of the file
  #
  # Example:
  #
  #   DiskCache.filepath('http://example.com/test123.jpg')
  #   # => "cache/9a/e2/74d94c34542ddd1b64667c1d4e392211ff67"
  #
  # Returns a Sting with the full path and filename
  def filepath(url)
    hsh = hash url
    path_h(hsh) + filename_h(hsh)
  end

  # Public: this removes all contents of the cache.
  def clear!
    if File.exists? cache_dir
      Dir.glob(cache_dir + '*').each do |f|
        FileUtils.rm_r f
      end
    end
  end

  private

  # Internal: Hashes a given piece of data with SHA1
  #
  # datum - piece of data to be hashed
  #
  # Examples:
  #
  #   hash('hi')
  #   # => "c22b5f9178342609428d6f51b2c5af4c0bde6a42"
  #
  # Returns String with hexdigest
  def hash(datum)
    Digest::SHA1.new.hexdigest(escape(datum))
  end

  # Internal: Return the directory of the cache as a String
  def cache_dir
    Dir.pwd + '/cache/'
  end

  # Internal: Calculate a path from a hash
  #
  # hsh - the hash
  #
  # Example:
  #
  #   path_h('9ae274d94c34542ddd1b64667c1d4e392211ff67')
  #   # => "cache/9a/e2/"
  def path_h(hsh)
    dir = hsh[0..1] + '/'
    subdir = hsh[2..3] + '/'
    cache_dir + dir + subdir
  end

  # Internal: calculate the path from a URL
  #
  # url - The URL to the file
  #
  # Example:
  #
  #   path('http://example.com/test123.jpg')
  #   # => "cache/9a/e2/"
  def path(url)
    path_h hash(url)
  end

  # Internal: calculate the filename from a hash
  #
  # hsh - the hash
  #
  # Example:
  #
  #   filename_h('9ae274d94c34542ddd1b64667c1d4e392211ff67')
  #   # => "74d94c34542ddd1b64667c1d4e392211ff67"
  def filename_h(hsh)
    hsh[4..-1]
  end

  # Internal: escape a given url
  #
  # url - the URL to escape
  #
  # Example:
  #
  #   url_escape('http://example.com/hello world')
  #   # => "http://example.com/hello%20world"
  #
  # Returns a String with the escaped url
  def escape(url)
    return URI.escape(url) if url.include? ' '
    url
  end
end
