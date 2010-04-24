require 'rubygems'
require 'sinatra'
require 'fileutils'

PAGES_DIRECTORY = File.expand_path('../pages', __FILE__)

FileUtils.mkdir_p PAGES_DIRECTORY

def page_path(title)
  PAGES_DIRECTORY + '/' + title
end

get '/' do
  "Welcome to our wiki"
end

get '/new' do
  erb :form
end

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
