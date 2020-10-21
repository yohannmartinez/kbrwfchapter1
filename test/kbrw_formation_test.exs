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

    test "can delete value of table by id" do
      table_delete_response = Database.delete("test")
      assert table_delete_response == true
    end

    test "can update value of table by id" do
      table_update_response = Database.update("test", "changed the value of test")
      assert table_update_response == true
    end
  end 
end
