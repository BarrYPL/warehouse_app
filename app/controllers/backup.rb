class Backup
    @@mainUrl = "https://files.multi.ovh/warehouse_bk"
    @@filePath = "db/database.db"

    attr_reader :response
    attr_reader :path
    attr_reader :last_hash
    attr_reader :last_date

    def initialize
      @response = RestClient.get(@@mainUrl+"?json")
      check_last_date
      check_last_hash
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
      if File.exists?(@@filePath)
        private_resource = RestClient.put @@mainUrl+"/#{full_name}", :myfile => File.new(@@filePath, 'rb')
        puts private_resource
      end
    end
end
