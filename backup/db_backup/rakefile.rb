#dump mysql db
namespace :db do

  namespace :dump do
    white_list = %w(db1 db2 db3)
    white_list.each { |d| d.strip!}

    black_list = %w(db1 db2 db3)
    black_list.each { |d| d.strip!}

    def get_dbnames
      `echo show databases | mysql -u root`.lines
    end

    all_databases = get_dbnames
    all_databases.each { |d| d.strip!}

    except_databases = %w(mysql information_schema Database)
    except_databases.each { |d| d.strip!}

    task :white_mode do
      log "--------------------------------"
      log "Starting db dump (white list)..."
      white_list.each do |d|
        Rake::Task["db:dump:#{d}"].invoke
      end
    end

    task :black_mode do
      log "--------------------------------"
      log "Starting db dump (black list)..."
      all_databases.each do |d|
        next if black_list.include?(d)
        next if except_databases.include?(d)
        # Rake::Task["db:dump:#{d}"].invoke
        dump(d)
      end
    end

    task :all do
      log "--------------------------------"
      log "Starting db dump (all)..."
      all_databases.each do |d|
        next if except_databases.include?(d)
        Rake::Task["db:dump:#{d}"].invoke
      end
    end

    all_databases.each do |t|
      desc "Dump database #{t.to_s.capitalize}" 
      task t do
        log "Dumping database #{t}..."
        dump(t)
      end
    end

    def dump(db)
      dump_options = "--default-character-set=utf8 --opt --extended-insert --triggers -R --hex-blob --single-transaction"
      dest_dir ||= ENV['PWD']
      dest_file = File.join(dest_dir, "#{db.to_s}.#{current_timestamp}.sql.bz2" )
      last_file = File.join(dest_dir, "../last", "#{db.to_s}.sql.bz2" )
      log "mysqldump -u root #{dump_options} #{db} | bzip2 -c > #{dest_file}"
      `mysqldump -u root #{dump_options} #{db} | bzip2 -c > #{dest_file}`
      `ln -sf #{dest_file} #{last_file}`
    end

    def current_timestamp(spliter="T")
      Time.now.strftime("%Y-%m-%d#{spliter}%H:%M:%S")
    end
    
    def current_timestamp
      Time.now.strftime("%Y%m%d%H%M%S")
    end
    
    def log(msg = "")
      puts "#{current_timestamp} #{msg}"
    end

  end     
end
