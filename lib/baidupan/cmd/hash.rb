class Hash
  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end
end