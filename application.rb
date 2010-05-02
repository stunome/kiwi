require 'rubygems'
require 'sinatra'
require 'fileutils'

# --- Storage ----------------------------------------------------------------
PAGES_DIRECTORY = File.expand_path('../pages', __FILE__)
FileUtils.mkdir_p PAGES_DIRECTORY

# --- Helpers ----------------------------------------------------------------
helpers do

  def page_path(title)
    PAGES_DIRECTORY + '/' + title
  end

end

# --- Homepage ----------------------------------------------------------------
get '/' do
  @pages = Dir.entries(PAGES_DIRECTORY).reject { |file| file =~ /^\./ }
  erb :homepage
end

# --- New page ----------------------------------------------------------------
get '/new' do
  erb :form
end

# --- Create page -------------------------------------------------------------
post '/pages' do

  # Empty title?
  if params['title'].nil? || params['title'] == ''
    return erb :form
  end

  # Sanitize filename (/, .)
  filename = params['title'].gsub( /(\\|\/)/, '' ).gsub(/\./, '_')

  puts "*** Creating page #{filename}"

  File.open page_path(filename), 'w' do |file|
    file.write params['body']
  end

  redirect '/'
end

# --- Show page ---------------------------------------------------------------
get "/pages/:title" do |title|
  @title = title
  @body = File.read page_path(title)
  erb :page
end

# --- Edit page ---------------------------------------------------------------
get "/pages/edit/:title" do |title|
  @title = title
  @body  = File.read page_path(title)
  erb :form
end
