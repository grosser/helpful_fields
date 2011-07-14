class Hash
  # {'x'=>{'y'=>{'z'=>1}}.value_from_nested_key('x[y][z]') => 1
  def value_from_nested_key(key)
    if key.to_s.include?('[')
      match, first, nesting = key.to_s.match(/(.+?)\[(.*)\]/).to_a
      value = self[first]
      nesting.split('][').each do |part|
        return nil unless value.is_a?(Hash)
        value = value[part]
      end
      value
    else
      self[key]
    end
  end
end
