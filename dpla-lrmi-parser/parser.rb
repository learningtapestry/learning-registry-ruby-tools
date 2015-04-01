# Setup deps.
require 'rubygems'
require 'bundler'
Bundler.setup

require 'json'

# Yajl:FFI will be used for streaming the JSON parsing.
require 'yajl'
require 'yajl/ffi'

# Setup the LT environment.

path = File::expand_path(File::dirname(__FILE__))

# The builder will generate an individual LR document from the partial JSON stream.
# Stolen from yajl-ffi.
class Builder
  METHODS = %w[start_document end_document start_object end_object start_array end_array key value]

  attr_reader :result

  def start_document
    @stack = []
    @keys = []
    @result = nil
  end

  def end_document
    @result = @stack.pop
  end

  def start_object
    @stack.push({})
  end

  def end_object
    return if @stack.size == 1

    node = @stack.pop
    top = @stack[-1]

    case top
    when Hash
      top[@keys.pop] = node
    when Array
      top << node
    end
  end
  alias :end_array :end_object

  def start_array
    @stack.push([])
  end

  def key(key)
    @keys << key
  end

  def value(value)
    top = @stack[-1]
    case top
    when Hash
      top[@keys.pop] = value
    when Array
      top << value
    else
      @stack << value
    end
  end
end

class Store
  attr_accessor :documents

  def initialize
    self.documents = []
  end

  def add(document)
    self.documents << document
  end
end

def get_parser(store)
  object_stack_size = 0
  current_doc = nil
  in_doc = false

  parser = Yajl::FFI::Parser.new

  parser.start_object do
    object_stack_size += 1

    if object_stack_size == 1
      current_doc = Builder.new
      current_doc.start_document
      current_doc.start_object
      in_doc = true
    else
      current_doc.start_object
    end
  end

  parser.end_object do
    object_stack_size -= 1

    if object_stack_size == 0
      current_doc.end_document
      in_doc = false

      store.add(current_doc.result)
    else
      current_doc.end_object
    end
  end

  parser.start_array do
    if in_doc
      current_doc.start_array
    end
  end

  parser.end_array do
    if in_doc
      current_doc.end_array
    end
  end

  parser.key do |key|
    if in_doc
      current_doc.key(key)
    end
  end

  parser.value do |value|
    if in_doc
      current_doc.value(value)
    end
  end

  parser
end

def parse_file(filename)
  store = Store.new
  parser = get_parser(store)

  File.open(filename) do |file|
    until file.eof?
      parser << file.read(8192)
    end
  end

  puts "#{store.documents.size} documents parsed."

  store.documents.each_with_index do |doc, i|
    preview = JSON.dump(doc)[0..70]
    puts "Document #{i} preview:"
    puts "--> #{preview}..."
  end
end

filename = "#{path}/data/dpla-nypl.json"
puts filename
parse_file(filename)
