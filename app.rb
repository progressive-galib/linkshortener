require 'sinatra'
require 'sqlite3'

configure do
  set :views, 'views'
  set :public_folder, 'public'
  db = SQLite3::Database.new 'urls.db'
  db.execute 'CREATE TABLE IF NOT EXISTS urls (id INTEGER PRIMARY KEY, original_url TEXT, short_url TEXT)'
end

get '/' do
  erb :index
end

post '/shorten' do
  original_url = params[:original_url]
  short_url = generate_short_url

  db.execute('INSERT INTO urls (original_url, short_url) VALUES (?, ?)', [original_url, short_url])

  redirect '/'
end

get '/:short_url' do
  short_url = params[:short_url]
  result = db.get_first_row('SELECT original_url FROM urls WHERE short_url = ?', [short_url])

  if result
    redirect result[0]
  else
    'URL not found'
  end
end

helpers do
  def generate_short_url
    rand(36**8).to_s(36) # Generate a random 8-character string
  end

  def db
    SQLite3::Database.new 'urls.db'
  end
end
