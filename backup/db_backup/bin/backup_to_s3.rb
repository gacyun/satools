#!/usr/bin/env ruby

require 'rubygems'
require 'aws/s3'
require 'yaml'

CONFIG_FILE = File.expand_path('../config', File.dirname(__FILE__)) + '/s3_backup.yml'

# Functions
def load_config
	conf = YAML.load_file(CONFIG_FILE)
end

def s3_config
	load_config["s3_config"]
end

def init_s3
  AWS::S3::Base.establish_connection!(
    :access_key_id     => s3_config["access_key_id"],
    :secret_access_key => s3_config["secret_access_key"]
  )
  # AWS::S3::Bucket.create(backup_db_config["bucket"])
end

def backup_to_s3
  # Process all configuration sets start with backup_
  init_s3
  load_config.each do |backup_sets|
    next unless backup_sets[0] =~ /s3_backup_/ 
    backup_set =  backup_sets[1]
    tag = backup_set['tag']
    backup_set['files'].each do |f|
      puts f
      AWS::S3::S3Object.store(File.join(tag, Time.now.strftime("%Y%m"), Time.now.strftime("%d"), File.basename(f)), open(f), backup_set['bucket'])
    end
  end
end

# Start
if s3_config["enabled"] == true
  backup_to_s3
else
  puts "backup to s3 has been disabled"
end
