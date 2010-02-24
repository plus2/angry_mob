class Pathname
  def self.here(file)
    Pathname(file).dirname.expand_path
  end
end
