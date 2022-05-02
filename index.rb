require 'sinatra'
require 'mysql2'
require 'logger'
require_relative 'db/dbconnector.rb'
require_relative 'db/model/dbTChatManager.rb'
require_relative 'db/model/dbTUserManager.rb'

@@logger = Logger.new('sinatra.log')

configure do
  enable :sessions
  #外部アクセスを許容
  set :bind, '0.0.0.0'
end

before do 
  dbM = DbConnector.new()
  @@db_client ||= dbM.db_client()
end

get '/' do
  erb :index
end

######################################################
# ログイン

get '/account' do
  erb :account
end

post '/account' do
  dbUserM = DbTUserManager.new()
  errors = dbUserM.user_push(params)
  unless errors.empty?
    errors.each do |key, val|
      err_text = val
    end
    erb :account, locals: {
      fails: errors.map{ |key, value| value }
    }
  else
    redirect '/'
  end
end

post '/login' do
  dbUserM = DbTUserManager.new()
  user = dbUserM.user_fetch(params)
  @@logger.info user
  if user
    session[:session_id] = SecureRandom.uuid
    session_save(session[:session_id], { name: user['name'] })
    redirect '/chat'
  else
    erb :index, locals: {
      fails: '入力内容に謝りがあります'
    }
  end
end

get '/logout' do
  session[:session_id] = nil
  redirect '/'
end

######################################################
# チャット

get '/chat' do
  @@logger.info '--chat-----------'
  @@logger.info session[:user_data]
  dbTChatM = DbTChatManager.new()
  chats = dbTChatM.chats_fetch()
  erb :chat, locals: {
    chats: chats.map{ |chat| add_suffix(chat) },
    name: session[:user_data][:name]
  }
end

post '/chat' do
  dbTChatM = DbTChatManager.new()
  dbTChatM.chat_push(params['content'])
  redirect back
end

######################################################
# 各ファンクション

def add_suffix(chat)
  { **chat, content: "#{chat[:content]}も" }
end

def chat_push(content, name="名無し")
  @@db_client.prepare(
    "INSERT into chats (name, content, time) VALUES (?, ?, NOW())"
  ).execute(name, content)
end

def chats_fetch()
  @@db_client.query("SELECT * FROM chats ORDER BY time DESC")
end


######################################################
# セッション
def session_save(session_id, obj)
  @@db_client.prepare(
    "INSERT into sessions (session_id, value_json) VALUES (?, ?)"
  ).execute(session_id, JSON.dump(obj))
  session[:user_data] = obj
end

#def session_fetch(session_id)
#  return if session_id == ""
#  result = @@db_client.prepare("SELECT * FROM sessions WHERE session_id = ?").execute(session_id).first
#  return unless result
#  JSON.parse(result&.[](:value_json))
#end