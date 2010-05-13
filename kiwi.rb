class Page

  def self.all
    Dir.entries(PAGES_DIRECTORY).reject { |file| file =~ /^\./ }
  end

end
