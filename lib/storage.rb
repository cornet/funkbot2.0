require 'redis'
require 'json'

module Funkbot
  class Storage

    # Public: Setup connection to redis
    #
    # plugin     - The plugin name String
    # connection - Hash containing the connection details
    #
    # Returns storage object
    def initialize(plugin, connection = {})
      @redis = Redis.new(connection)
      @base  = plugin
    end

    # Public: Check if key exists
    #
    # key - The String to check
    #
    # Returns True if exists, False if not
    def has_key?(key)
      @redis.exists(ns_key(key))
    end

    # Public: Get key value
    #
    # key - The String or Symbol key to lookup
    #
    # Returns the value Object or nil
    def [](key)
      unserialize(@redis.get(ns_key(key)))
    end

    # Public: Save a key to redis
    #
    # key   - The String or Symbol key
    # value - The Object to save
    #
    # Returns nothing
    def []=(key, value)
      @redis.set ns_key(key), serialize(value)
    end

    # Public: Delete a key
    #
    # key - The String or Symbol of the key to delete
    #
    # Returns nothing
    def delete(key)
      @redis.del ns_key(key)
    end

    private

    # Private: Serialize an object as JSON
    #
    # object - The Object to serialize
    #
    # Returns the JSON String object
    def serialize(object)
      # JSON.parse("hello".to_json) doesn't work.
      # So lets stick everything in a hask
      {:value => object}.to_json
    end

    # Private: Unserialize a JSON Object
    #
    # object - The Object to serialize
    #
    # Returns the JSON String
    def unserialize(object)
      if object.nil?
        nil
      else
        JSON.parse(object)['value']
      end
    end

    # Private: Namespace a key
    #
    # key - String or Symbol key to namespace
    #
    # Returns the namespaced key String
    def ns_key(key)
      "#{@base}::#{key.to_s}"
    end

  end
end
