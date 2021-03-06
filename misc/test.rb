require 'test/unit'


class NoLimitTest < Test::Unit::TestCase
  def setup
    `curl -X POST http://localhost:8000 -d "foo=bar"`
  end

  def test_write
    result = `curl -X POST http://localhost:8000 -d "test=1234"`
    assert_equal result, "ok" 
  end

  def test_read
    result = `curl http://localhost:8000/?key=foo`
    assert_equal result, "bar"
  end

  def test_delete
    `curl -X DELETE http://localhost:8000/?key=foo`
    result = `curl http://localhost:8000/?key=foo`
    assert_equal result, "not found"
  end

  def test_multiget
    10.times do |i|
      `curl -X POST http://localhost:8000 -d "test#{i}=asdf"`
    end
    result = `curl http://localhost:8000/?keys=test0,test1,test2,test3,test4,test5,test6,test7,test8,test9`
    expected = "{\"test0\":\"asdf\",\"test1\":\"asdf\",\"test2\":\"asdf\",\"test3\":\"asdf\",\"test4\":\"asdf\",\"test5\":\"asdf\",\"test6\":\"asdf\",\"test7\":\"asdf\",\"test8\":\"asdf\",\"test9\":\"asdf\"}" 
    assert_equal result, expected 
  end

  def test_ttl
    `curl -X POST http://localhost:8000 -d "expire_test=1234" -d "ttl=1"`
    sleep 2
    result = `curl http://localhost:8000/?key=expire_test`
    assert_equal result, "not found"
  end

end
