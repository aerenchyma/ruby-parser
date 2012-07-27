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

def parse_expression(input)
  
  num = input.shift
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  
  return num.value if input.empty?
  
  op = input.shift
  if op.type != :plus
    raise "Syntax error: expecting plus"
  end
  num.value + parse_expression(input)
end



tokens = lex_input("    1 + 3 + 2     +7    ") # answer should be 13
puts parse_expression(tokens)