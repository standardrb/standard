val = true
puts val

# Should only be fixed unsafely
# https://github.com/standardrb/standard-performance/issues/8
h = {a: 1, b: 2, c: 3}.count { |k, v| v.odd? }
puts h
