class DbConnector
    def db_client()
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        Mysql2::Client.new(
          :host => ENV['MYSQL_HOST'],
          :username => ENV['MYSQL_USER'],
          :password => ENV['MYSQL_PASS'],
          :database => ENV['MYSQL_DATABASE']
        )
    end    
end