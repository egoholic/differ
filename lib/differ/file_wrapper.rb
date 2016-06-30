module Differ
  class FileWrapper
    attr_accessor :cursor

    def initialize(fpath)
      raise ArgumentError, "'fpath' should be a string"     unless fpath.instance_of? String
      raise ArgumentError, "file \"#{fpath}\" is not found" unless File.exists? fpath

      text = File.read(fpath) 

      @text       = text.split("\n")
      @cursor     = 0
      @max_cursor = @text.length + 1
    end

    def next
      line = @text[@cursor]
      @cursor += 1
      line
    end

    def next?
      @cursor < @max_cursor
    end
  end
end
