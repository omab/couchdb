#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'throw'


$options = OpenStruct.new
$options.db = nil
$options.docs = []

optparser = OptionParser.new do |opts|
  opts.banner = 'Usage: upload-views.rb [options]'

  opts.on('-d', '--db=', 'CouchDB Database name') do |d|
    $options.db = d
  end

  opts.on('-n', '--doc-name=', 'Design document name') do |d|
    $options.docs << d
  end
end

optparser.parse!

if $options.db.nil? || $options.doc.empty?
  puts "Wrong options\n\n"
  puts optparser
  exit 1
end

def load_views(doc_name)
  views = {}

  Dir["**/#{doc_name}/views/*"].each do |path|
    if path.ends_with? '.js'
      content = File.open(path, 'r'){|f| f.readlines.join}
      name = path.split('/').last.gsub(/\.js$/, '')
      details = name.rpartition('-')
      name, type = details.first.to_sym, details.last.to_sym
      views[name] ||= {}
      views[name][type] = content
    end
  end

  views
end

def load_lists(doc_name)
  lists = {}

  Dir["**/#{doc_name}/lists/*"].each do |path|
    if path.ends_with? '.js'
      content = File.open(path, 'r'){|f| f.readlines.join}
      name = path.split('/').last.gsub(/\.js$/, '')
      lists[name] = content
    end
  end

  lists
end

server = Throw::Server.new($options.db)

$options.docs.each do |name|
  design = {
    views: load_views(name),
    lists: load_lists(name)
  }.select{|k, v| !v.nil? && !v.empty?}

  server.update_design(name, design)
end
