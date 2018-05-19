defmodule CatalogApi.CoercionTest do
  use ExUnit.Case

  alias CatalogApi.Coercion

  describe "integer_fields_to_boolean/3" do
    test "coerces a field to a boolean value" do
      boolean_fields = [:bool]
      map = %{bool: 1, num: 1}
      assert %{bool: true, num: 1} = Coercion.integer_fields_to_boolean(map, boolean_fields)
      map = %{bool: 0, num: 0}
      assert %{bool: false, num: 0} = Coercion.integer_fields_to_boolean(map, boolean_fields)
      map = %{bool: "1", num: "1"}
      assert %{bool: true, num: "1"} = Coercion.integer_fields_to_boolean(map, boolean_fields)
      map = %{bool: "0", num: "0"}
      assert %{bool: false, num: "0"} = Coercion.integer_fields_to_boolean(map, boolean_fields)
    end

    test "returns a map if return_map is true" do
      boolean_fields = [:bool]
      map = %{bool: 1, num: 1}
      assert %{bool: true, num: 1} = Coercion.integer_fields_to_boolean(map, boolean_fields)
    end

    test "returns a keyword list if return_map is false" do
      boolean_fields = [:bool]
      map = %{bool: 1, num: 1}
      assert [bool: true, num: 1] = Coercion.integer_fields_to_boolean(map, boolean_fields, false)
    end

    test "returns an error tuple for the field if it cannot be coerced" do
      boolean_fields = [:bool]
      map = %{bool: "maybe"}
      assert %{bool: {:error, :failed_boolean_coercion}} =
        Coercion.integer_fields_to_boolean(map, boolean_fields)
    end
  end

  describe "boolean_fields_to_integer/3" do
    test "coerces a field to an integer value" do
      boolean_fields = [:bool]
      map = %{bool: true, num: true}
      assert %{bool: 1, num: true} = Coercion.boolean_fields_to_integer(map, boolean_fields)
      map = %{bool: "true", num: true}
      assert %{bool: 1, num: true} = Coercion.boolean_fields_to_integer(map, boolean_fields)
      map = %{bool: false, num: true}
      assert %{bool: 0, num: true} = Coercion.boolean_fields_to_integer(map, boolean_fields)
      map = %{bool: "false", num: true}
      assert %{bool: 0, num: true} = Coercion.boolean_fields_to_integer(map, boolean_fields)
    end

    test "returns a map if return_map is true" do
      boolean_fields = [:bool]
      map = %{bool: true, num: true}
      assert %{bool: 1, num: true} = Coercion.boolean_fields_to_integer(map, boolean_fields, true)
    end

    test "returns a keyword list if return_map is false" do
      boolean_fields = [:bool]
      map = %{bool: true, num: true}
      assert [bool: 1, num: true] = Coercion.boolean_fields_to_integer(map, boolean_fields, false)
    end

    test "returns an error tuple for the field if it cannot be coerced" do
      boolean_fields = [:bool]
      map = %{bool: "maybe"}
      assert %{bool: {:error, :failed_integer_coercion}} =
        Coercion.boolean_fields_to_integer(map, boolean_fields)
    end
  end
end
