class Hash
  def deep_copy
    binding.pry
    Marshal.load(Marshal.dump(self))
  end
end