gem "minitest"
require 'minitest/autorun'
require '../learningregistry'
require 'fileutils'
require 'json'

class LRModuleTest < Minitest::Test

  # This test doesn't validate that an empty resumption token actually exists
  def test_retrieve_all_records
    # limit test to first four resumption payloads
    LR::max_resumptions = 2
    LR::retrieve_all_records(:node => 'http://sandbox.learningregistry.org', 
      :folder => @temp, :quiet => true)
    # validate that all retrieved entries are valid json
    Dir.glob(File::join("#{@temp}","**", "*")) do |file|  
      if File::file?(file) then
        data = File::read(file)
        json = JSON.parse(data)
        assert true
      end
    end
  end

  def test_tree_balancing
    id = 'xyz'
    data = 'abc'
    test_path = LR::tree_balanced_write(id, @temp, data)
    test_file = File::read(test_path)
    assert_equal data, test_file
    test_dir = File::dirname(test_path)
    # limit max files in folder to something sane for testing
    LR::max_entries_in_tree = 100
    # put more files than that in the folder
    (0..200).each do |i|
      FileUtils::touch(File::join(test_dir, i.to_s))
    end
    assert Dir::entries(test_dir).size > 200
    id = 'xyz'
    data = 'abc'
    # verify that new file is placed deeper into hierarchy
    deeper_test_path = LR::tree_balanced_write(id, @temp, data)
    assert_equal File::dirname(File::dirname(deeper_test_path)), test_dir
  end
  def setup
    @temp = Dir::mktmpdir("lr_test")
  end
  def teardown
    FileUtils::rmtree(@temp)
  end
end