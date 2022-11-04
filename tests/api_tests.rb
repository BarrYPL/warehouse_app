require 'rest-client'
require 'json'
require 'test-unit'

class TestWarehouseApi < Test::Unit::TestCase

  def test_api_connection
    $url = "127.0.0.1/api/v1/items"
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
    $hash = JSON.parse(response.body).first
    assert_equal("Item Not Found", $hash["error"])

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
    $url = "127.0.0.1/api/v1/items"
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
    $url = "127.0.0.1/api/v1/items/"
    begin
     response = RestClient.get($url+"0")
    rescue RestClient::ExceptionWithResponse => e
      $hash = JSON.parse(e.response.body)
      assert_equal("Item Not Found", $hash["error"])
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
     assert_equal("Ilość nie może być ujemna!", $hash["error"])

     #Need url without slath at the end
     $url = $url[..-2]
     #Try to pass empty type name
     begin
       response = RestClient.post $url, {"new-type-name" => "", "new-item-checkbox" => "create-type" , "new-item-name" => "11"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa typu nie może być pusta!", $hash["error"])
     end

     #Try to pass wrong type name
     begin
       response = RestClient.post $url, {"new-type-name" => "śróby1", "new-item-checkbox" => "create-type" , "new-item-name" => "11"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa typu może składać się tylko z małych znaków a-z i spacji!", $hash["error"])
     end

     #Try post new item only with name
     begin
      response = RestClient.post $url, {"new-item-name" => "item1"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Wybierz rodzaj!", $hash["error"])
     end

     #Try create element without element type
     begin
       response = RestClient.post $url, {"new-item-name" => "", "element" => "testowy_typ"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa elementu nie może być pusta!", $hash["error"])
     end

     #Try to pass name and type
     begin
      response = RestClient.post $url, {"element" => "testowy_typ", "new-item-name" => "11"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa musi zawierać przynajmniej jedną literę!", $hash["error"])
     end

     #Try to pass too long element name
     begin
      response = RestClient.post $url, {"new-item-name" => "#{"a"*31}", "element" => "testowy_typ"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa nie może być dłuższa niż 30 znaków!", $hash["error"])
     end

     #Try to pass too long type name
     begin
      response = RestClient.post $url, {"new-type-name" => "#{"a"*31}", "new-item-name" => "testowy_item", "new-item-checkbox" => "create-type"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Nazwa nie może być dłuższa niż 30 znaków!", $hash["error"])
     end

     #Try create element with letters in quantity
     begin
      response = RestClient.post $url, {"new-item-name" => "asd", "element" => "testowy_typ", "new-item-quantity" => "a"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("W tym polu ilość mogą znajdować się tylko cyfry!", $hash["error"])
     end

     #Try create element with negative quantity
     begin
      response = RestClient.post $url, {"new-item-name" => "asd", "element" => "testowy_typ", "new-item-quantity" => "-123"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Ilość nie może być ujemna!", $hash["error"])
     end

     #Create item with existing ID
     begin
      response = RestClient.post $url, {"new-item-name" => "asd", "element" => "testowy_typ", "new-item-localid" => "aasd"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Istnieje już element o podanym ID!", $hash["error"])
     end

     #Create item with negative value
     begin
      response = RestClient.post $url, {"new-item-name" => "asd", "element" => "testowy_typ", "new-item-value" => "-1"}
     rescue RestClient::ExceptionWithResponse => e
       $hash = JSON.parse(e.response.body)
       assert_equal("Wartość nie może być mniejsza od 0!", $hash["error"])
     end

     $url = "127.0.0.1/api/v1/add_element"
     #Trying add quantity with wrong ID
     response = RestClient.post $url, {"added_quantity" => "1", "item_id" => ""}
     $hash = JSON.parse(response.body)
     assert_equal("Błędne ID!", $hash["error"])

     #trying add 0 quantity
     response = RestClient.post $url, {"added_quantity" => "0", "item_id" => "aasd"}
     $hash = JSON.parse(response.body)
     assert_equal("Wprowadzono niewłaściwą wartość!", $hash["error"])

     #trying add negative quantity
     response = RestClient.post $url, {"added_quantity" => "-2", "item_id" => "aasd"}
     $hash = JSON.parse(response.body)
     assert_equal("O kolego, za dużo to i świnia nie przeżre!", $hash["error"])
   end

   def test_api_functions
      $url = "127.0.0.1/api/v1/add_element"
      #Adding +1 quantity through API
      response = RestClient.get("127.0.0.1/api/v1/items", {params: {'name' => 'aasd'}})
      $hash = JSON.parse(response.body).first
      quantity = $hash["quantity"]
      response = RestClient.post $url, {"added_quantity" => "1", "item_id" => "aasd"}
      $hash = JSON.parse(response.body)
      assert_equal(quantity.to_i + 1, $hash["quantity"].to_i)

      $url = "127.0.0.1/api/v1/items"
      #Add new item
      response = RestClient.post $url, {"element" => "testowy_typ", "new-item-name" => "test1", "new_item_quantity" => "1", "new-item-value" => "4k"}
      $url = response.headers[:location] #url for the next request
      assert_equal(201, response.code)

      #Check item value
      response = RestClient.get $url
      $hash = JSON.parse(response.body)
      assert_equal(4000.0, $hash["value"])

      #response = RestClient.patch $url, {"name-input" => "item2"}
      #$hash = JSON.parse(response.body)
      #assert_equal("item2", $hash["name"])

      #deleting item
      @id = JSON.parse(response.body)["localid"]
      $url = $url.match(/^(.*?).*items\//).match(0)
      response = RestClient.delete $url + @id
      assert_equal(204, response.code)
   end
end
