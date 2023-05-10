class Backup
    @@mainUrl = "https://files.multi.ovh/warehouse_bk"
    @@filePath = "db/database.db"

    attr_reader :response
    attr_reader :path
    attr_reader :last_hash
    attr_reader :last_date
    attr_reader :remote_connection

    def initialize
      if check_connection
        @response = RestClient.get(@@mainUrl+"/?order=asc&sort=mtime&json")
        check_last_date
        check_last_hash
      end
    end

    def check_connection
      dns_resolver_bk  = Resolv::DNS.new()
      begin
        dns_resolver_bk.getaddress("files.multi.ovh")
        @remote_connection = true
      rescue
        p "Backup.rb: Can not connect to: files.multi.ovh"
        @remote_connection = false
      end
      return @remote_connection
    end

    def show_paths
      @paths = JSON.parse(@response)
    end

    def check_last_hash
      show_paths
      if !@paths["paths"].empty?
        @last_hash = @paths["paths"].last["name"].split("_")[0]
      end
    end

    def check_last_date
        show_paths
        if !@paths["paths"].empty?
          @last_date = @paths["paths"].last["name"].split("_")[1]
        end
    end

    def compare_names(hash)
      check_last_hash
      if (hash == @last_hash)
        return true
      else
        return false
      end
    end

    def upload_db
      date = Time.now.strftime("%d-%m-%Y")
      hash = Digest::MD5.file("db/database.db").hexdigest
      full_name = "#{hash}_#{date}.db"
      if File.exist?(@@filePath)
        private_resource = RestClient.put @@mainUrl+"/#{full_name}", File.open(@@filePath, 'rb')
      end
    end
end
