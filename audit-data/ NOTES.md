# my understanding of the project

- Enter a raffle to win a doggie NFT
- enterRaffle() raffle is called with an array of addresses
- Cant use duplicate addresses
  - can enter in different raffle
  - @audit but can i enter multiple time in the same raflle ?
- Users should be refunded if they call the refund function
  - @audit check if the refund is working
- Every X seconds, the raffle will be able to draw a winner and be minted a random puppy // @audit duration is set to 1 day from starting block

- The owner of the protocol will set a feeAddress to take a cut of the value, and the rest of the funds will be sent to the winner of the puppy.

  - @audit to check the veritable value cut from the owner
  - @audit calculate and check the winner's cut

- Owner - Deployer of the protocol, has the power to change the wallet address to which fees are sent through the changeFeeAddress function.
  - @audit Check if we can change the FeeAddress() to a different address
- Player - Participant of the raffle, has the power to enter the raffle with the enterRaffle function and refund value through refund function.

- @audit at deployment:

  - feeAddress is set to msg.sender
  - entranceFee to 1e18 in wei -> 1 ether
  - duration to 1 day

- @audit users should be refunded what they paid minus the transaction fee
- @audit can guess the winner by checking the block number and difficulty and the number of players

- @audit can guess the rarity by using the msg.sender address and block.difficulty %100

# To verify / questions

// @audit i - removes unecessary loop to avoid DOS attacks
// @audit i - check if the owner can change the fee address

// @audit - need to change the way of using foor loops to check for duplicates. can lead to a DOS attack and blowing up the gas floor which will lead to unusable contract for users. too expensive.

    /*///////////
     ENTRANCE FEE
    ///////////*/

// @audit q - DOS attack pretty difficult to pay entranceFee when there is 30 players. because 30 \* 1e18 = 30 ether so what if 100 players enter the raffle ? more the player numbers grow, more the entranceFee grows. so the entranceFee should be a fixed value or a percentage of the total value of the raffle.
DOS attack -> block gas limit exploit, a way to impeach the transaction to go through, or to revert it on a malicious contract each time in the fallback and receive function by putting some condition or acceptance of an asset / gas amount necessary etc..., or a too much highly cost transaction like keeping adding people in an array and multiplying the next entrance fee based on the previous entered number of people...

// @audit q - what if entrance fee is 0 ? can we enter the raffle for free ?
// @audit q - what if the first player choose to get refund after other players entered. -> free entry and compensated exit ?

// @audit it also have a MEV attack in this function, front running the transaction

    /*///////////
     Refund
    ///////////*/

// @audit the 101th player is refunded 1 eth but had to pay 100 eth to enter
// @audit first player get paid for leaving, and starting from the second player, players doesnt get refunded what they paid

--> need a player / entrancefee mapping to refund the right amount to the right player

    /*///////////
     getActivePlayerIndex
    ///////////*/

// @audit q - what if the active player is at index 0? Player won`t be considered as active. -> 2 approach use maxuint or boolean + index

    /*///////////
     Drawing a winner
    ///////////*/

// @audit should manage the state of the raffle by using enum instead of conditionals

# To change

- @audit naming convetions on variables
  s* for storage var. i* for immutable or full caps etc...

# Vector of attack

At least 4 highs hidden

Type:

-
-

{
"COMMON_RARITY()": "bd71a521",
"LEGENDARY_RARITY()": "bd7c40c7",
"RARE_RARITY()": "db2c0b91",
"approve(address,uint256)": "095ea7b3",
"balanceOf(address)": "70a08231",
"baseURI()": "6c0360eb",
"changeFeeAddress(address)": "285e1406",
"enterRaffle(address[])": "e1a0f7e7",
"entranceFee()": "649677e1",
"feeAddress()": "41275358",
"getActivePlayerIndex(address)": "db2cea75",
"getApproved(uint256)": "081812fc",
"isApprovedForAll(address,address)": "e985e9c5",
"name()": "06fdde03",
"owner()": "8da5cb5b",
"ownerOf(uint256)": "6352211e",
"players(uint256)": "f71d96cb",
"previousWinner()": "5c6059ee",
"raffleDuration()": "b2f8846b",
"raffleStartTime()": "3be539ee",
"rarityToName(uint256)": "970c76e1",
"rarityToUri(uint256)": "4a038beb",
"refund(uint256)": "278ecde1",
"renounceOwnership()": "715018a6",
"safeTransferFrom(address,address,uint256)": "42842e0e",
"safeTransferFrom(address,address,uint256,bytes)": "b88d4fde",
"selectWinner()": "33a99e04",
"setApprovalForAll(address,bool)": "a22cb465",
"supportsInterface(bytes4)": "01ffc9a7",
"symbol()": "95d89b41",
"tokenByIndex(uint256)": "4f6ccce7",
"tokenIdToRarity(uint256)": "6be88980",
"tokenOfOwnerByIndex(address,uint256)": "2f745c59",
"tokenURI(uint256)": "c87b56dd",
"totalFees()": "13114a9d",
"totalSupply()": "18160ddd",
"transferFrom(address,address,uint256)": "23b872dd",
"transferOwnership(address)": "f2fde38b",
"withdrawFees()": "476343ee"
}

{
"storage": [
{
"astId": 45381,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_supportedInterfaces",
"offset": 0,
"slot": "0",
"type": "t_mapping(t_bytes4,t_bool)"
},
{
"astId": 45837,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_holderTokens",
"offset": 0,
"slot": "1",
"type": "t_mapping(t_address,t_struct(UintSet)48202_storage)"
},
{
"astId": 45839,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_tokenOwners",
"offset": 0,
"slot": "2",
"type": "t_struct(UintToAddressMap)47579_storage"
},
{
"astId": 45843,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_tokenApprovals",
"offset": 0,
"slot": "4",
"type": "t_mapping(t_uint256,t_address)"
},
{
"astId": 45849,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_operatorApprovals",
"offset": 0,
"slot": "5",
"type": "t_mapping(t_address,t_mapping(t_address,t_bool))"
},
{
"astId": 45851,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_name",
"offset": 0,
"slot": "6",
"type": "t_string_storage"
},
{
"astId": 45853,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_symbol",
"offset": 0,
"slot": "7",
"type": "t_string_storage"
},
{
"astId": 45857,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_tokenURIs",
"offset": 0,
"slot": "8",
"type": "t_mapping(t_uint256,t_string_storage)"
},
{
"astId": 45859,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_baseURI",
"offset": 0,
"slot": "9",
"type": "t_string_storage"
},
{
"astId": 45265,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_owner",
"offset": 0,
"slot": "10",
"type": "t_address"
},
{
"astId": 48447,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "players",
"offset": 0,
"slot": "11",
"type": "t_array(t_address)dyn_storage"
},
{
"astId": 48449,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "raffleDuration",
"offset": 0,
"slot": "12",
"type": "t_uint256"
},
{
"astId": 48451,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "raffleStartTime",
"offset": 0,
"slot": "13",
"type": "t_uint256"
},
{
"astId": 48453,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "previousWinner",
"offset": 0,
"slot": "14",
"type": "t_address"
},
{
"astId": 48455,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "feeAddress",
"offset": 0,
"slot": "15",
"type": "t_address"
},
{
"astId": 48458,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "totalFees",
"offset": 20,
"slot": "15",
"type": "t_uint64"
},
{
"astId": 48462,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "tokenIdToRarity",
"offset": 0,
"slot": "16",
"type": "t_mapping(t_uint256,t_uint256)"
},
{
"astId": 48466,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "rarityToUri",
"offset": 0,
"slot": "17",
"type": "t_mapping(t_uint256,t_string_storage)"
},
{
"astId": 48470,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "rarityToName",
"offset": 0,
"slot": "18",
"type": "t_mapping(t_uint256,t_string_storage)"
},
{
"astId": 48473,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "commonImageUri",
"offset": 0,
"slot": "19",
"type": "t_string_storage"
},
{
"astId": 48482,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "rareImageUri",
"offset": 0,
"slot": "20",
"type": "t_string_storage"
},
{
"astId": 48491,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "legendaryImageUri",
"offset": 0,
"slot": "21",
"type": "t_string_storage"
}
],
"types": {
"t_address": {
"encoding": "inplace",
"label": "address",
"numberOfBytes": "20"
},
"t_array(t_address)dyn_storage": {
"encoding": "dynamic_array",
"label": "address[]",
"numberOfBytes": "32",
"base": "t_address"
},
"t_array(t_bytes32)dyn_storage": {
"encoding": "dynamic_array",
"label": "bytes32[]",
"numberOfBytes": "32",
"base": "t_bytes32"
},
"t_array(t_struct(MapEntry)47253_storage)dyn_storage": {
"encoding": "dynamic_array",
"label": "struct EnumerableMap.MapEntry[]",
"numberOfBytes": "32",
"base": "t_struct(MapEntry)47253_storage"
},
"t_bool": {
"encoding": "inplace",
"label": "bool",
"numberOfBytes": "1"
},
"t_bytes32": {
"encoding": "inplace",
"label": "bytes32",
"numberOfBytes": "32"
},
"t_bytes4": {
"encoding": "inplace",
"label": "bytes4",
"numberOfBytes": "4"
},
"t_mapping(t_address,t_bool)": {
"encoding": "mapping",
"key": "t_address",
"label": "mapping(address => bool)",
"numberOfBytes": "32",
"value": "t_bool"
},
"t_mapping(t_address,t_mapping(t_address,t_bool))": {
"encoding": "mapping",
"key": "t_address",
"label": "mapping(address => mapping(address => bool))",
"numberOfBytes": "32",
"value": "t_mapping(t_address,t_bool)"
},
"t_mapping(t_address,t_struct(UintSet)48202_storage)": {
"encoding": "mapping",
"key": "t_address",
"label": "mapping(address => struct EnumerableSet.UintSet)",
"numberOfBytes": "32",
"value": "t_struct(UintSet)48202_storage"
},
"t_mapping(t_bytes32,t_uint256)": {
"encoding": "mapping",
"key": "t_bytes32",
"label": "mapping(bytes32 => uint256)",
"numberOfBytes": "32",
"value": "t_uint256"
},
"t_mapping(t_bytes4,t_bool)": {
"encoding": "mapping",
"key": "t_bytes4",
"label": "mapping(bytes4 => bool)",
"numberOfBytes": "32",
"value": "t_bool"
},
"t_mapping(t_uint256,t_address)": {
"encoding": "mapping",
"key": "t_uint256",
"label": "mapping(uint256 => address)",
"numberOfBytes": "32",
"value": "t_address"
},
"t_mapping(t_uint256,t_string_storage)": {
"encoding": "mapping",
"key": "t_uint256",
"label": "mapping(uint256 => string)",
"numberOfBytes": "32",
"value": "t_string_storage"
},
"t_mapping(t_uint256,t_uint256)": {
"encoding": "mapping",
"key": "t_uint256",
"label": "mapping(uint256 => uint256)",
"numberOfBytes": "32",
"value": "t_uint256"
},
"t_string_storage": {
"encoding": "bytes",
"label": "string",
"numberOfBytes": "32"
},
"t_struct(Map)47261_storage": {
"encoding": "inplace",
"label": "struct EnumerableMap.Map",
"numberOfBytes": "64",
"members": [
{
"astId": 47256,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_entries",
"offset": 0,
"slot": "0",
"type": "t_array(t_struct(MapEntry)47253_storage)dyn_storage"
},
{
"astId": 47260,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_indexes",
"offset": 0,
"slot": "1",
"type": "t_mapping(t_bytes32,t_uint256)"
}
]
},
"t_struct(MapEntry)47253_storage": {
"encoding": "inplace",
"label": "struct EnumerableMap.MapEntry",
"numberOfBytes": "64",
"members": [
{
"astId": 47250,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_key",
"offset": 0,
"slot": "0",
"type": "t_bytes32"
},
{
"astId": 47252,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_value",
"offset": 0,
"slot": "1",
"type": "t_bytes32"
}
]
},
"t_struct(Set)47816_storage": {
"encoding": "inplace",
"label": "struct EnumerableSet.Set",
"numberOfBytes": "64",
"members": [
{
"astId": 47811,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_values",
"offset": 0,
"slot": "0",
"type": "t_array(t_bytes32)dyn_storage"
},
{
"astId": 47815,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_indexes",
"offset": 0,
"slot": "1",
"type": "t_mapping(t_bytes32,t_uint256)"
}
]
},
"t_struct(UintSet)48202_storage": {
"encoding": "inplace",
"label": "struct EnumerableSet.UintSet",
"numberOfBytes": "64",
"members": [
{
"astId": 48201,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_inner",
"offset": 0,
"slot": "0",
"type": "t_struct(Set)47816_storage"
}
]
},
"t_struct(UintToAddressMap)47579_storage": {
"encoding": "inplace",
"label": "struct EnumerableMap.UintToAddressMap",
"numberOfBytes": "64",
"members": [
{
"astId": 47578,
"contract": "src/PuppyRaffle.sol:PuppyRaffle",
"label": "_inner",
"offset": 0,
"slot": "0",
"type": "t_struct(Map)47261_storage"
}
]
},
"t_uint256": {
"encoding": "inplace",
"label": "uint256",
"numberOfBytes": "32"
},
"t_uint64": {
"encoding": "inplace",
"label": "uint64",
"numberOfBytes": "8"
}
}
}
