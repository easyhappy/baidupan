class Hash
  def to_query_str
    map{|k, v| "&#{k}=#{v}"}.join
  end
end