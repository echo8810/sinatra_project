require_relative '../dbconnector.rb'

class DbTChatManager
    def db_client
        dbManager = DbConnector.new()
        @db_client = dbManager.db_client
    end

    def chat_push(content, name="名無し")
        db_client.prepare(
          "INSERT into chats (name, content, time) VALUES (?, ?, NOW())"
        ).execute(name, content)
    end
      
    def chats_fetch()
        dbManager = DbConnector.new()
        db_client = dbManager.db_client
        db_client.query("SELECT * FROM chats ORDER BY time DESC")
    end
end