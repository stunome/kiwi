class Page

  attr_accessor :title, :body

  def initialize(attributes={})
    @title = attributes[:title]
    @body  = attributes[:body]
  end

  def self.all
    Dir.entries(PAGES_DIRECTORY).reject { |file| file =~ /^\./ }
  end

  def save
    FileUtils.mkdir_p path

    File.open path + '/' + Time.now.to_i.to_s , 'w' do |file|
      file.write body
    end
  end

  def path
    PAGES_DIRECTORY + '/' + title
  end

end