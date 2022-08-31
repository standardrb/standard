# Some code that violates lots of rules

require "json"

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
  alias_method :do_more_stuff, :do_stuff

  attr_reader :foo
  def do_stuff(a:, b:, c:)
    maths_and_stuff = 4 +
      5 +
      6

    plus_stuff = STUFF.map do |e|
      e + 1 + maths_and_stuff
    end

    STUFF.tap { |arr| arr.delete(0) }

    STUFF.each { |e| e.succ }

    THINGS.tap { |things|
      if THINGS.is_a?(Hash)
        42 + 8
      end
    }

    test = "hi"
    test2 = "hi"
    test3 = test.equal?(test2)
    if test3
      32 + 3
    end
    THINGS.keys.each { |key|
      THINGS[key] = plus_stuff[i]
    }
  end

  def do_even_more_stuff
    do_stuff(
      a: 1,
      b: 2,
      c: 3
    )
  rescue
    nil
  end
end

# some alignment opinions
class AlignyStuff
  def self.enum(options)
    a = 3
    a + 4
  end

  enum event_type: {
    thing_1: 0,
    thing_2: 1,
    longer_thing: 2,
    even_longer_thing: 3,
  }

  def setup_fog_credentials(config)
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV["S3_ACCESS_KEY"],
      aws_secret_access_key: ENV["S3_SECRET"],
      region: ENV["S3_REGION"],
    }

    config.fog_credentials_as_kwargs(
      provider: "AWS",
      aws_access_key_id: ENV["S3_ACCESS_KEY"],
      aws_secret_access_key: ENV["S3_SECRET"],
      region: ENV["S3_REGION"],
    )
  end
end

def bad_function(a:, b:, test: true)
  if test
    /[xy]/ =~ a
  else
    b
  end
end

def count_carbs(food)
  carbs = case food
  when :pancakes
    23
  when :mushrooms
    4
  end
  carbs + 1
end
