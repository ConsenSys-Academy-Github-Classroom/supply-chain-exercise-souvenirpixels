// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner;

  uint public skuCount;

  mapping(uint => Item) items;

  enum State {ForSale, Sold, Shipped, Received}

  struct Item {string name;
               uint sku;
               uint price;
               State state;
               address payable seller;
               address payable buyer;
              }
  
  /* 
   * Events
   */

  event LogForSale(uint sku);

  event LogSold(uint sku);

  event LogShipped(uint sku);

  event LogReceived(uint sku);


  /* 
   * Modifiers
   */

  // Mdifer, `isOwner` that checks if the msg.sender is the owner of the contract
  modifier isOwner () { 
    require(msg.sender == owner, 'Caller not owner');
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    // uint _price = items[_sku].price;
    // uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(uint _sku) {
    require(items[_sku].state == State.ForSale, "Item not for sale");
    require(items[_sku].price != 0, "Item not for sale");
    _;
  }
  modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold, 'Item is not sold');
    _;
  }
  modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped, 'Item has not shipped');
    _;
  }
  
  modifier received(uint _sku) {
    require(items[_sku].state == State.Received, 'Item has not been received');
    _;
  }

  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary? < No it isn't necessary
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true

    address payable seller = msg.sender;
    address payable buyer = address(0);

    items[skuCount] = Item({
      name: _name, 
      sku: skuCount, 
      price: _price, 
      state: State.ForSale, 
      seller: seller, 
      buyer: buyer
    });
    
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint sku) public payable paidEnough(items[sku].price) forSale(sku) {
    items[sku].seller.transfer(items[sku].price);
    address payable buyer = msg.sender;
    items[sku].buyer = buyer;
    items[sku].state = State.Sold;    
    emit LogSold(sku);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public sold(sku) {
    require(items[sku].seller == msg.sender, 'Only seller can ship');
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public shipped(sku) {
    require(items[sku].buyer == msg.sender, 'Only buyer can receive');
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view  
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
   { 
     name = items[_sku].name; 
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     seller = items[_sku].seller; 
     buyer = items[_sku].buyer; 
     return (name, sku, price, state, seller, buyer); 
   } 
}
