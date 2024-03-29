require 'mysql2'
require 'minitest/autorun'

def assert_record_not_exists(client, table_name, condition_column, condition_value)
  query = "SELECT * FROM #{table_name} WHERE #{condition_column} = '#{condition_value}' LIMIT 1"

  result = client.query(query)

  # Use assert to check if the record exists
  assert(result.count == 0, "Record found for #{condition_column}=#{condition_value}")
end

class TestRecordExistence < Minitest::Test
  def setup
    @client = Mysql2::Client.new(
      host: "54.201.36.55",
      username: "test_user",
      password: "test_user",
      database: "fat_free_crm_development"
    )
  end

  def teardown
    @client.close if @client
  end

  def test_record_not_exists_after_deletion
    table_name = "accounts"
    condition_column = "name"
    condition_value = "chaita"

    assert_record_not_exists(@client, table_name, condition_column, condition_value)
  end
end
