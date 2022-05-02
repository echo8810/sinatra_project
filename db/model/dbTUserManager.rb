require_relative '../dbconnector.rb'
require 'logger'
require 'bcrypt'

@@logger = Logger.new('sinatra.log')

class DbTUserManager
    def db_client
        dbManager = DbConnector.new()
        @db_client = dbManager.db_client
    end

    def user_push(params)
        now = Time.now
        errors = validate(params)
        if errors.empty?
            securePass = password_digest(params['pass'])
            db_client.prepare(
              "INSERT into users (name, email, password, created_at, updated_at) VALUES (?, ?, ?, ?, ?)"
            ).execute(params['name'], params['email'], securePass, now, now)
            return errors
        else
            return errors
        end
    end
      
    def user_fetch(params)
        result = db_client.prepare("SELECT * FROM users WHERE email = ?").execute(params['email']).first
        @@logger.info '----user_fetch----------'
        @@logger.info result
        return unless result[:id]
        if result[:password] == password_digest(params['pass'])
            res = Hash.new()
            res['name' ] = result[:name]
            res['email'] = result[:email]
            return res 
        else
            return false
        end
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
        unless params['name'].nil?
            errors['alr_user'] = '既に登録されているユーザ名です' if db_client.prepare("SELECT * FROM users WHERE name = ?").execute(params['name']).first
        end

        # 文字列長不足
        unless params['pass'].nil? || params['pass'].empty?
            errors['pass_len'] = 'パスワードは８文字以上必要です' if params['pass'].length < 8
        end
        
        return errors
    end

    private def password_digest(pass)
        securePass = ""
        salt = "DPrtG32EBrlD@mX-kaO4sE++wwq2"
        pass_digest = Digest::MD5.hexdigest(pass)
        salt_digest = Digest::MD5.hexdigest(salt)
        Digest::MD5.hexdigest(pass_digest + salt_digest)
    end

end