#Some code that violates lots of rules

STUFF = [
  1,
          3,
          4,
          5
        ]

THINGS = {
    :oh => :io,
    :hi => 'neat'
    }

class Something


    def do_stuff( a,b,c )
        plus_stuff = STUFF.map do |e|
            e+1
        end

        STUFF.tap { |arr| arr.delete(0) }


        THINGS.tap { |things|
          if THINGS.kind_of?(Hash)
            42 + 8
          end
        }

        THINGS.keys.each { |key|
            if ( plus_stuff.reduce(:+) > 1 )
                THINGS[key] = plus_stuff[i]
            end
        }
    end

end
