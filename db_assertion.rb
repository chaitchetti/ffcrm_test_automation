require 'mysql2'
require 'minitest/autorun'

def assert_record_exists(client, table_name, condition_column, condition_value)
  query = "SELECT * FROM #{table_name} WHERE #{condition_column} = '#{condition_value}' LIMIT 1"

  result = client.query(query)

  # Use assert to check if the number of rows is greater than 0
  assert(result.count == 0, "Record not found for #{condition_column}=#{condition_value}")
end

class TestRecordExistence < Minitest::Test
  def setup
    @client = Mysql2::Client.new(
      host: "34.218.237.182",
      username: "dbuser",
      password: "dbuser",
      database: "fat_free_crm_development"
    )
  end

  def teardown
    @client.close if @client
  end

  def test_record_exists
    table_name = "accounts"
    condition_column = "name"
    condition_value = "test_user"

    assert_record_exists(@client, table_name, condition_column, condition_value)
  end
end
