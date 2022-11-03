require 'rest-client'
require 'json'
require 'test-unit'

class TestWarehouseApi < Test::Unit::TestCase
  $url = "127.0.0.1/api/v1/items"

  def test_api_connection
    #Test case for basic searching functions

    #show all items it's 315
    response = RestClient.get($url)
    $hash = JSON.parse(response.body)
    assert_equal(314, $hash.length)

    #search API for STM phrase should find 4 results
    response = RestClient.get($url, {params: {'name' => 'STM'}})
    $hash = JSON.parse(response.body)
    assert_equal(4, $hash.length)

    #search API for mx phrase should find 0 results
    response = RestClient.get($url, {params: {'name' => 'mx'}})
    $hash = JSON.parse(response.body)
    assert_equal("Item Not Found", $hash.first["message"])

    #search API for empty name should find 315 results
    response = RestClient.get($url, {params: {'name' => ''}})
    $hash = JSON.parse(response.body)
    assert_equal(314, $hash.length)

    #search API for id should find 1 result with const name
    response = RestClient.get($url+"/1")
    $hash = JSON.parse(response.body)
    assert_equal("27 Ohm", $hash["name"])
  end

  def test_api_menaging
    #Tests case for adding, chaning and deleting item

    #adding item named "item1"
    #required params
    #element => "testory_typ" //rodzaj elementu
    #new-item-name => "nazwa_elementu"
    #new-item-quantity => "ilość elementów"
    response = RestClient.post $url, {"element" => "testowy_typ", "new-item-name" => "item1", "new_item_quantity" => "123"}
    $url = response.headers[:location] #url for the next request
    assert_equal(201, response.code)

    #changing item name to "item2"
    #required params
    #name-input => "new_name"
    #id => "id_elementu" //ID pobierane z headera poprzedniej odpowiedzi
    response = RestClient.patch $url, {"name-input" => "item2"}
    $hash = JSON.parse(response.body)
    assert_equal("item2", $hash["name"])

    #deleting item
    #required params
    #id => "id_elementu"
    response = RestClient.get $url
    @id = JSON.parse(response.body)["localid"]
    $url = $url.match(/^(.*?).*items\//).match(0)
    response = RestClient.delete $url + @id
    assert_equal(204, response.code)

    #At the end number of existing items should have been same as at the start of testing
    response = RestClient.get($url[..-2])
    $hash = JSON.parse(response.body)
    assert_equal(314, $hash.length)
  end

  #
  # Need API auth!!!
  #

  def tests_of_incorrest_requests
    begin
     response = RestClient.get($url+"0")
    rescue RestClient::ExceptionWithResponse => e
      $hash = JSON.parse(e.response.body)
      assert_equal("Item Not Found", $hash["message"])
     end

     #Possible params to test:
     #
     #name-input
     #quantity-input
     #location-input
     #unit-input
     #power-input
     #voltage-input
     #type-input
     #description-input
     #datasheet-input

     #Change test item name to "item2"
     response = RestClient.patch $url+"aasd", {"name-input" => "item2"}
     $hash = JSON.parse(response.body)
     assert_equal("item2", $hash["name"])

     #Change test item quantity to 1
     response = RestClient.patch $url+"aasd", {"quantity-input" => "1"}
     $hash = JSON.parse(response.body)
     assert_equal(1, $hash["quantity"])

     #Try to change test item quantity to negative value.
     response = RestClient.patch $url+"aasd", {"quantity-input" => "-1"}
     $hash = JSON.parse(response.body)
     assert_equal(1, $hash["quantity"])
  end
end
