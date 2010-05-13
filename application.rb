require 'rubygems'
require 'sinatra'
require 'fileutils'
require 'bluecloth'

require 'kiwi'

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
  @pagetitle = 'Vítejte'
  @pages = Page.all
  erb :homepage
end

# --- New page ----------------------------------------------------------------
get '/new' do
  @pagetitle = 'Vytvořit novou stránku'
  erb :form
end

# --- Create page -------------------------------------------------------------
post '/pages' do

  # Empty title?
  if params['title'].nil? || params['title'] == ''
    return erb :form
  end

  # Sanitize folder name (/, .)
  folder_name = params['title'].gsub( /(\\|\/)/, '' ).gsub(/\./, '_')

  puts "*** Creating page #{folder_name}"

  FileUtils.mkdir_p page_path(folder_name)

  File.open page_path(folder_name) + '/' + Time.now.to_i.to_s , 'w' do |file|
    file.write params['body']
  end

  redirect '/'
end

# --- Show page ---------------------------------------------------------------
get "/pages/:title" do |title|
  @title = @pagetitle = title
  content = File.read page_path(title) + '/' + Dir.entries( page_path(title) ).last
  @body = BlueCloth.new( content ).to_html
  @revisions = Dir.entries( page_path(title) ).reject { |file| file =~ /^\./ }
  erb :page
end

# --- Edit page ---------------------------------------------------------------
get "/pages/edit/:title" do |title|
  @title = title
  @pagetitle = "Upravit stránku '#{@title}'"
  @body  = File.read page_path(title) + '/' + Dir.entries( page_path(title) ).last
  erb :form
end

# --- Show page revision ------------------------------------------------------
get "/pages/:title/revisions/:timestamp" do |title, timestamp|
  @title = title
  @pagetitle = "#{title} &mdash; revize z #{Time.at(timestamp.to_i).strftime('%d/%m/%Y %H:%M')}"
  content = File.read page_path(title) + '/' + timestamp
  @body = BlueCloth.new( content ).to_html
  @revisions = Dir.entries( page_path(title) ).reject { |file| file =~ /^\./ }
  erb :page
end
