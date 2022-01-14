require_relative '../dbconnector.rb'
require 'logger'

@@logger = Logger.new('sinatra.log')

class DbTUserManager
    def db_client
        dbManager = DbConnector.new()
        @db_client = dbManager.db_client
    end

    def user_push(params)
        now = Time.now
        errors = validate(params)
        @@logger.info errors
        if errors.empty?
            db_client.prepare(
              "INSERT into users (name, email, password, created_at, updated_at) VALUES (?, ?, ?, ?, ?)"
            ).execute(params['name'], params['email'], params['pass'], now, now)
            return false
        else
            return errors
        end
    end
      
    def user_fetch(params)
        result = db_client.prepare("SELECT * FROM users WHERE name = ?").execute(params['name']).first
        return unless result
        result[:password] == params['pass'] ? result : nil
    end

    def validate(params)
        errors = Hash.new()
        # 必須
        
        errors['name' ] = 'ユーザ名が未入力です' if params['name'].nil? || params['name'].empty?
        errors['email'] = 'メールが未入力です' if params['email'].nil? || params['email'].empty?
        errors['pass' ] = 'パスワードが未入力です' if params['pass'].nil? || params['pass'].empty?

        # PASS確認
        errors['pass_diff'] = 'パスワード確認が相違しています' if params['passConf'] != params['pass']

        # 既存ユーザー名
        #unless params['name'].nil?
        #    errors['alr_user'] = '既に登録されているユーザ名です' if db_client.prepare("SELECT * FROM users WHERE name = ?").execute(params['name'])
        #end

        # 文字列長不足
        unless params['pass'].nil? || params['pass'].empty?
            errors['pass_len'] = 'パスワードは８文字以上必要です' if params['pass'].length < 8
        end
        
        return errors
    end
end