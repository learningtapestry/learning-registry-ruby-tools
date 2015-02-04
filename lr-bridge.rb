require 'slop'
require 'json'
require 'digest'
require './learningregistry'

#lr-bridge --node node01.public.learningregistry.net --start [date] --end [date]
# sandbox.learningregistry.org
# returns a msg to user if an opt is required but not present
def require_opt(opt, opts)
  if !opts[opt] then
    return "--#{opt} is a required parameter\n"
  end
  ""
end

# takes an array of symbols and makes sure they are present
def require_opts(requirements, opts)
  required = ""
  requirements.each do |opt|
    required += require_opt(opt, opts)
  end
  if required.length > 0 then
    STDERR.puts required
    STDERR.puts
    STDERR.puts opts
    exit 1
  end
end

opts = Slop.parse do
  on 'n', 'node=', 'LR node to access (include http[s]://)'
  on 'f', 'folder=', 'Folder to save resources in (will be created if not found)'
  on 's', 'start=', 'Start date for extraction (not yet implemented!)'
  on 'u', 'until=', 'End date for extraction (not yet implemented!)'
  on '?', 'help=', 'View this help'
end

if opts[:help] then
  o.separator "For very large datasets do not use start/end parameter. \n"+
   "First download all records, then pull small sets using start/end parameters."

  puts opts.to_s
  exit
end

# Enforce required params
required_opts = [:node, :folder]
require_opts(required_opts, opts)

node = opts[:node]
folder = opts[:folder]
start = opts[:start]
to = opts[:until]

if !start && !to then
  LR::retrieve_all_records(node: node, folder: folder)
else
  LR::retrieve_records_by_date(node: node, folder: folder, start: start, until: to)
end





