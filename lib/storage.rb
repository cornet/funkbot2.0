require 'sequel'
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
      puts plugin
      puts connection
      @db = Sequel.connect(connection)
      @ds = @db[:store]
      @plugin = plugin
    end

    # Public: Check if key exists
    #
    # key - The String to check
    #
    # Returns True if exists, False if not
    def has_key?(key)
      !@ds.where(:plugin => @plugin, :key => key).empty?
    end

    # Public: Get key value
    #
    # key - The String or Symbol key to lookup
    #
    # Returns the value Object or nil
    def [](key)
      unserialize @ds.where(:plugin => @plugin, :key => key).get(:value)
    end

    # Public: Save a key to redis
    #
    # key   - The String or Symbol key
    # value - The Object to save
    #
    # Returns nothing
    def []=(key, value)
      upsert(key, serialize(value))
    end

    # Public: Delete a key
    #
    # key - The String or Symbol of the key to delete
    #
    # Returns nothing
    def delete(key)
      @ds.where(:plugin => @plugin, :key => key).delete
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

    # Private: Update existing key or insert new if not already present
    #
    # key - String or Symbol of key
    # value - String containing the value
    #
    # Returns true if succesful, false if not
    def upsert(key, value)
      rec = @ds.where(:plugin => @plugin, :key => key)
      if 1 != rec.update(:value => value)
        @ds.insert(:plugin => @plugin, :key => key, :value => value)
      end
    end
  end
end
