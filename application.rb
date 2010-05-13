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

  puts "*** Creating page '#{params[:title]}'"

  page = Page.new(:title => params[:title], :body => params[:body])

  if page.valid?
    page.save
    redirect '/'
  else
    erb :form
  end

end

# --- Show page ---------------------------------------------------------------
get "/pages/:title" do |title|
  @page = Page.find(title)
  if @page
    @pagetitle = @page.title
    @revisions = Dir.entries( page_path(title) ).reject { |file| file =~ /^\./ }
    erb :page
  else
    not_found "Stránka nenalezena"
  end
end

# --- Edit page ---------------------------------------------------------------
get "/pages/edit/:title" do |title|
  @page = Page.find(title)
  if @page
    @pagetitle = "Upravit stránku '#{@page.title}'"
    @revisions = Dir.entries( page_path(title) ).reject { |file| file =~ /^\./ }
    erb :form
  else
    not_found "Stránka nenalezena"
  end
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
