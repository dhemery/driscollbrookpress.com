module ISBN
  BOOKLAND = '978'
  PUBLISHER_GROUP = '1'
  DRISCOLL_BROOK_PRESS = '63261'

  ISBN10_FORMULA = {
      prefix: [PUBLISHER_GROUP, DRISCOLL_BROOK_PRESS],
      checksum_multipliers: [10, 9, 8, 7, 6, 5, 4, 3, 2],
      check_digit: lambda do |checksum|
        check_digit = (11 - (checksum % 11)) % 11
        check_digit == 10 ? 'X' : check_digit
      end
  }
  ISBN13_FORMULA = {
      prefix: [BOOKLAND] + ISBN10_FORMULA[:prefix],
      checksum_multipliers: [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3],
      check_digit: lambda do |checksum|
        (10 - (checksum % 10)) % 10
      end
  }

  def isbn10(title, separator = '')
    isbn(ISBN10_FORMULA, title, separator)
  end

  def isbn13(title, separator = '')
    isbn(ISBN13_FORMULA, title, separator)
  end

  def isbn(formula, title, separator)
    isbn_parts = formula[:prefix] + ['%03d' % title]
    checksum = isbn_parts.join.chars.map(&:to_i)
                   .zip(formula[:checksum_multipliers])
                   .map {|digit, multiplier| digit * multiplier}
                   .reduce(&:+)
    check_digit = formula[:check_digit].call(checksum).to_s
    isbn_parts <<= check_digit
    isbn_parts.join(separator)
  end

  class Calculator
    include ISBN
  end

  CALCULATOR = Calculator.new
end

Liquid::Template.register_filter(ISBN)
