defmodule KbrwFormationTest do
  use ExUnit.Case
  alias KbrwFormation.Database
  doctest KbrwFormation

  describe "table tests" do
    test "table exist" do
      table_response = Database.get("test")
      assert table_response == nil
    end

    test "can put in table" do
      table_put_response = Database.put("test", "this is a test value")
      assert table_put_response == true
    end

    test "can get value of table by id" do
      table_get_response = Database.get("test")
      assert table_get_response == {"test", "this is a test value"}
    end
  end 
end
