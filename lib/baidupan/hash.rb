class Hash
  def self.deep_copy
    binding.pry
    Marshal.load(Marshal.dump(self))
  end
ends