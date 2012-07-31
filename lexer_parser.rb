class Token < Struct.new(:type, :value)
  def inspect
    "[:#{type}, #{value || "nil"}]"
  end
end

$operators = [:times, :div, :plus, :minus, :exp]
$muldiv = [:times, :div]
$plusmin = [:plus, :minus]
$other_ops = [:exp]

def lex_input(input)
  tokens = []
  while input.length > 0
    if input =~ /^(\d+)/
      num = $1
      input = input.sub(num, '')
      tokens << Token.new(:number, num.to_i)
    elsif input =~ /^\^/
      input = input[1..-1]
      tokens << Token.new(:exp, nil)
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

def parse_sum(input) # for sum
  num = input[0]
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  sum = input.shift.value
  return sum if input.empty?
  
  while !input.empty?
    
    op = input[0] # looking at next token
    n = input[1]
    
    if !$operators.include?(op.type)
      #puts $operators
      raise "Syntax error: expecting operator, got #{op.type}"
    elsif !n || n.type != :number
      raise "Syntax error: expecting number, got #{n ? n.type : "nothing"}" 
    elsif op.type == :plus
      input.shift # eat plus/minus op
      sum += parse_product(input)
    elsif op.type == :minus
      input.shift # eat plus/minus op
      sum -= parse_product(input)
    elsif $muldiv.include?(op.type)
      input.unshift(num) # hmm
      sum += parse_product(input)
    end
  end
  sum
end


def parse_product(input)
  n = input.shift
  
  unless n.type == :number
    raise "Syntax error, expecting number, got #{input[0].type}"
  end
  
  product = n.value
  return product if input.empty?
  
  while !input.empty? && !$plusmin.include?(input[0].type) # this check could be more elegant
    n_op = input[0] # check -- peek at next values
    next_num = input[1]
    if !$operators.include?(n_op.type) # needed?
      raise "Syntax error, expecting operator, got #{n_op.type}"
    elsif next_num.type != :number
      raise "Syntax error, expecting number, got #{next_num.type}"
    elsif n_op.type == :times
      product *= parse_exponent(input)
      puts "first input, #{input}"
      input.shift(2)
      puts "input now, #{input}"
    elsif n_op.type == :div
      product /= parse_exponent(input)
      input.shift(2)
    end
  end
  product
end


def parse_exponent(input)
  n = input.shift
  
  unless n.type == :number
    raise "Syntax error: expecting number"
  end
  
  exp = n.value
  return n if input.empty?
  
  e_op = input.shift # intended to pick up and eat ^ op
  if !e_op || !$operators.include?(e_op.type)
    raise "Syntax error: expecting operator, found #{e_op ? e_op.type : "nothing"}"
  elsif input.empty? || input[0].type != :number
    raise "Syntax error: expecting number, got #{input[0] ? input[0].type : "nothing"}"
  elsif e_op.type == :exp
    n_num = input.shift
  end
  exp ** parse_exponent(input) # this fxn fully recursive
end



# code
      
tokens = lex_input("2+3*2*4 -6") 
puts parse_sum(tokens)   


### GRAMMAR
## sum: product {('+' | '-') product}*
## product: NUM {('*'|'/') NUM}*
    