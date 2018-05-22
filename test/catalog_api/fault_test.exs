defmodule CatalogApi.FaultTest do
  use ExUnit.Case
  doctest CatalogApi.Fault
  alias CatalogApi.Fault

  @base_fault_json %{
    "detail" => "detailed error message",
    "faultcode" => "Client.ExceptionType",
    "faultstring" => "general error message"
  }

  describe "extract_fault_from_json/1" do
    test "extracts the fault from a standard fault structure" do
      json = %{"Fault" => @base_fault_json}
      assert {:ok, %Fault{}} = Fault.extract_fault_from_json(json)
    end

    test "returns an error tuple for unrecognized fault structure" do
      json = %{"UnknownKey" => @base_fault_json}
      assert {:error, :unparseable_catalog_api_fault} = Fault.extract_fault_from_json(json)
    end
  end

  describe "cast/1" do
    test "produces a Fault struct from json" do
      fault = Fault.cast(@base_fault_json)
      assert %Fault{} = fault
      assert fault.detail == @base_fault_json["detail"]
      assert fault.faultcode == @base_fault_json["faultcode"]
      assert fault.faultstring == @base_fault_json["faultstring"]
    end
  end
end
