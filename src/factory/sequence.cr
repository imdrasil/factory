module Factory
  class Sequence
    @@start = 0

    def self.next
      @@start += 1
      @@start - 1
    end

    def self.current
      @@start
    end
  end
end
