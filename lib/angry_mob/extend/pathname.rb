require 'fileutils'

class Pathname
  def self.here(file)
    Pathname(file).dirname.expand_path
  end

  def pathname
    Pathname(self)
  end

  def touch
    FileUtils.touch(self)
  end

  def cp_to(to)
    FileUtils.cp(self,to)
  end

  def ls
    Pathname.glob(self+'*').reject {|e| e.basename.to_s[0] == '.'}
  end
end
