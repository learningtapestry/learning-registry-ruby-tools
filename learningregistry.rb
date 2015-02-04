require 'digest'
require 'http'
require 'json'
require 'tempfile'

module LR; class << self;
  # Purpose: write data into a file using tree balanced folders
  #   To be nice, we try to create the minimum depth of folders
  # Function: MD5 hash the tree_id and create a set of folders based on splitting
  #   tree_id = filename and hash basis for balanced tree
  #   base_folder = base folder to create the balanced tree
  #     base_folder is assumed to exist - errors occur if it doesn't.
  #   data   = string content to write into file
  # Will go deeper into MD5 hash if more than 10k files exist in a folder
  DEFAULT_MAX_ENTRIES_IN_TREE = 10000
  attr_accessor :max_entries_in_tree
  def tree_balanced_write(tree_id, base_folder, data)
    hash = Digest::MD5.hexdigest(tree_id)
    path = base_folder
    while (dir = hash.slice!(0..1)).size > 0 do
      path = File::join(path,dir)
      Dir::mkdir(path) if !Dir::exists?(path)
      break if Dir::entries(path).size < (max_entries_in_tree || DEFAULT_MAX_ENTRIES_IN_TREE)
    end
    path = File::join(path, tree_id)
    File::write(path, data)
    path
  end

  def harvest_url(node, options = {})
    from = options[:from]
    to = options[:until]
    "#{node}/harvest/listrecords?start=#{start}&until=#{to}"
  end

  def slice_url(node, options ={})
    "#{node}/slice"
  end

  # if set, this will stop retrive_all_records before completed (but simulates completion)
  # primarily for testing purposes
  attr_accessor :max_resumptions
  def retrieve_all_records(options)
    node = options[:node]
    base_folder = options[:folder]
    quiet = !!options[:quiet]
    Dir::mkdir(base_folder) if !Dir::exists?(base_folder)

    puts "Retrieving all records from LR node #{node}..." if !quiet
    resume = ""
    counts = {:loop => 0}
    x = 0
    print "Retrieving record blocks: " if !quiet
    # Loop through obtain API resumption tokens until none left
    while true do
      url = slice_url(node)
      params = resume.size > 0 ? {resumption_token: resume} : {}
      stream = HTTP.get(url, params: params).to_s
      begin
        json = JSON.parse(stream)
      rescue JSON::ParserError
        STDERR.puts "Rescuing parse error." if !quiet
        err_file = Dir::Tmpname.create("lr_parse_error") {}
        File::write(err_file, stream)
        stream += "]}"
        json = JSON.parse(stream)
      end
      resume = json["resumption_token"]
      json["documents"].each do |doc|
        tree_balanced_write(doc["doc_ID"], base_folder, doc.to_json) if doc["doc_ID"]
      end
      if !resume || resume.size < 1
        puts "\nResumption token empty - completed download successfully" if !quiet
        break 
      end
      x+=1
      print "#{x} " if !quiet
      if max_resumptions.kind_of?(Integer) && x > max_resumptions then
        break
      end
    end
  end

  def retrieve_records_by_date(options)
  end
end; end
