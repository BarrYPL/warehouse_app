require 'rest-client'
require 'json'
require 'test-unit'

class TestWarehouseApi < Test::Unit::TestCase
  $url = "127.0.0.1/api/v1/items"

  def test_api_connection
    #Test sace for basic searching functions

    #show all items it's 315
    response = RestClient.get($url)
    $hash = JSON.parse(response.body)
    assert_equal(314, $hash.length)

    #search API for STM phrase should find 4 results
    response = RestClient.get($url+"?name=STM")
    $hash = JSON.parse(response.body)
    assert_equal(4, $hash.length)

    #search API for mx phrase should find 0 results
    response = RestClient.get($url+"?name=mx")
    $hash = JSON.parse(response.body)
    assert_equal("Item Not Found", $hash.first["message"])

    #search API for empty name should find 315 results
    response = RestClient.get($url+"?name=")
    $hash = JSON.parse(response.body)
    assert_equal(314, $hash.length)

    #search API for id should find 1 result with const name
    response = RestClient.get($url+"/1")
    $hash = JSON.parse(response.body)
    assert_equal("27 Ohm", $hash["name"])
  end

  def test_api_menaging
    #adding item namsed "item1"
    #required params
    #element => "testory_typ" //rodzaj elementu
    #new-item-name => "nazwa_elementu"
    #new-item-quantity => "ilość elementów"

    #changing item name to "item2"
    #required params
    #name-input => "new_name"
    #id => "id_elementu" //Trzeba dopisać jakieś pobieranie ID

    #deleting item
    #required params
    #id => "id_elementu"
  end
end
