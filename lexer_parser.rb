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
    elsif input =~ /^\*/
      input = input[1..-1]
      tokens << Token.new(:times, nil)
    elsif input =~ /^\//
      input = input[1..-1]
      tokens << Token.new(:div, nil)
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

def multdiv_helper(input, newval) # mishandling operator without final number
  # assumes valid input -- maybe shouldn't
  multdiv = [:times, :div]
  while !input.empty? && multdiv.include?(input[0].type)
    new_op = input.shift
    next_num = input.shift
    if next_num && next_num.type == :number # with first check it accepts invalid input with trailing operator, with both it breaks but not my error
      if new_op.type == :times
        newval *= next_num.value
      elsif new_op.type == :div
        newval /= next_num.value
      end  
    end
  end
  input.shift(3) # -- yet with the shift in this line, no fix (see comment below fxn)
  return newval
end
# potential problem: it stops shifting, no longer a stream, breaks when it's wrong the wrong way 


def parse_expression(input)
  muldiv = [:times,:div]
  num = input.shift 
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  total = num.value
  return total if input.empty?
  
  while !input.empty?
    
    op = input.shift
    n = input.shift
    newval = n.value 

    if ![:plus, :minus, :times, :div].include?(op.type) 
      raise "Syntax error: expecting operator, got #{op.type}"
    elsif !n || n.type != :number
      raise "Syntax error: expected number, got invalid input"
    elsif op.type == :times
        total *= n.value
    elsif op.type == :div
      total /= n.value
    # begin peeking (and nesting)
    elsif input[1]
      #p input
      if input[1].type == :number && muldiv.include?(input[0].type) # first check here not correct...
        newval, input = multdiv_helper(input,newval)  
      elsif input[0].type != :number 
        raise "Syntax error: expected number, got invalid input" 
      end
    else
      newval = n.value
    end
    
    if op.type == :plus
      total += newval
    elsif op.type == :minus
      total -= newval
    end
  end
  total
end



# CODE/tests

#input_string = gets.chomp!  
#tokens = lex_input(input_string)

tokens = lex_input("    1 -  6  /2 + * 3 * 4 /  ")
#p tokens

puts parse_expression(tokens)