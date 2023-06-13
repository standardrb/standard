val = :true
puts val

# Should only be fixed unsafely
# https://github.com/standardrb/standard-performance/issues/8
h = {a: 1, b: 2, c: 3}.select { |k, v| v.odd? }.count
puts h
