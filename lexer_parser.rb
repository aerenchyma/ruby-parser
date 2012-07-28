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
    elsif input =~ /^-/
      input = input[1..-1]
      tokens << Token.new(:minus, nil)
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
  sum = num.value
  return sum if input.empty?
  
  while !input.empty?
    op = input.shift
    n = input.shift
    
   # if op.type != :plus && op.type != :minus
    if ![:plus, :minus].include?(op.type)
      raise "Syntax error: expecting operator, got #{op.value}"
    elsif !n || n.type != :number
      raise "Syntax error: expected number, got #{n ? n.type : 'nothing'}"
    elsif op.type == :plus
      sum += n.value
    elsif op.type == :minus
      sum -= n.value
    end
  end
  sum
end


tokens = lex_input("    1 - 3 + 2  +9  + 7  ") 
#p tokens
puts parse_expression(tokens)