# lexer and parser separate
# language with literal numbers and one binary operator ('+')

# thanks to David Albert & Jason Laster

require 'rubygems'
require 'pry'

class Token < Struct.new(:type, :value)
  def inspect
    "[:#{type}, #{value || "nil"}]"
  end
end

def lex_input(input)
  tokens = []
  
  while input.length > 0
    if input =~ /^(\d+)/
      num = $1
      input = input.sub(num, '')
      tokens << Token.new(:number, num.to_i)
    elsif input =~ /^\+/
      input = input[1..-1]
      tokens << Token.new(:plus, nil)
    elsif input =~ /^(\s+)/
      input = input.sub($1, '')
    else
      raise "Found invalid input at: #{input}"
    end
  end
  tokens
end


def parse_arithmetic(input)
  expr = input.shift(3) # this only works for exclusively-binary operators that return a single val
  #puts expr
  if not expr[0].type == :number and not expr[2].type == :number and not expr[1].type == :plus
    return false
  elsif expr.length == 1
    input.unshift(expr.first)
    return false
  end
  nt = Token.new(:number, expr[0].value + expr[2].value)
  input.unshift(nt)
end

def parse_expression(input)
  if parse_arithmetic(input) 
    parse_expression(input)
  elsif input[0].type == :number and input.length == 1
    input
  else 
    raise "Syntax error: invalid input"
  end
end











# code
tokens = lex_input("    1 + 3 + 2     +7    ") # answer should be 13
#tokens = lex_input("2 + + 3 +5")

## TESTS
# puts tokens
# p tokens
#puts parse_wrapper(tokens)
#puts parse_arithmetic(tokens)
#binding.pry
puts parse_expression(tokens)

# puts "hello"