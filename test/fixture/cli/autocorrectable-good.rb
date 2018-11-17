# Some code that violates lots of rules

STUFF = [
  1,
  3,
  4,
  5,
]

THINGS = {
  oh: :io,
  hi: "neat",
}

class Something
  def do_stuff(a, b, c)
    plus_stuff = STUFF.map { |e|
      e + 1
    }

    STUFF.tap { |arr| arr.delete(0) }

    THINGS.tap do |things|
      if THINGS.is_a?(Hash)
        42 + 8
      end
    end

    THINGS.keys.each do |key|
      if plus_stuff.reduce(:+) > 1
        THINGS[key] = plus_stuff[i]
      end
    end
  end
end
