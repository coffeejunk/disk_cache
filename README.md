# FileCache

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'file_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install file_cache

## Usage

```ruby
# to save an image in the cache
FileCache.put('http://example.com/1234abc.jpg')
#=> nil

# to get an image from the cache
FileCache.get('http://example.com/1234abc.jpg')
#=> #<File:1234abc.jpg>

# to delete an image from the cache
FileCache.del('http://example.com/1234abc.jpg')
#=> nil
```

All cached images are 

## TODO

- option to check if an image has changed (i.e. HTTP Last-Modified)

  ```ruby
  Net::HTTP.start("example.com") do |http|
    response = http.request_head('/1352127364208.png')
    puts response['Last-Modified']
  end
  ```

- option to change the path of the cache


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
