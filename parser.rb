def parse_expression(input)
  input = eat_whitespace(input)
  
  num, input = parse_number(input)
  
  unless num
    raise "Syntax error, expecting number"
  end
  
  input = eat_whitespace(input)
  
  return num if input.empty?
  
  if input[0] != '+'
    raise "Syntax error, expecting '+'"
  end
  
  # eat up the plus character
  input = input[1..-1]
  
  input = eat_whitespace(input)
  
  num + parse_expression(input)
end

def parse_number(input)
  if input =~ /^(\d+)/
    num = $1
    input = input.sub(num, '')
    num = num.to_i
    return num, input
  else
    return false, input
  end
end

def eat_whitespace(input)
  input.gsub(/^\s+/, '')
end


puts parse_expression("1 + 2 +     32 +      4    ")