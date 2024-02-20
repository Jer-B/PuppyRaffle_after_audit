**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [arbitrary-send-eth](#arbitrary-send-eth) (1 results) (High)
 - [weak-prng](#weak-prng) (1 results) (High)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [reentrancy-no-eth](#reentrancy-no-eth) (1 results) (Medium)
 - [missing-zero-check](#missing-zero-check) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (2 results) (Low)
 - [timestamp](#timestamp) (1 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (2 results) (Informational)
 - [cache-array-length](#cache-array-length) (3 results) (Optimization)
 - [constable-states](#constable-states) (4 results) (Optimization)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## arbitrary-send-eth
Impact: High
Confidence: Medium
 - [ ] ID-0
[PuppyRaffle.withdrawFees()](src/PuppyRaffle.sol#L254-L263) sends eth to arbitrary user
	Dangerous calls:
	- [(success) = feeAddress.call{value: feesToWithdraw}()](src/PuppyRaffle.sol#L261)

src/PuppyRaffle.sol#L254-L263


## weak-prng
Impact: High
Confidence: Medium
 - [ ] ID-1
[PuppyRaffle.selectWinner()](src/PuppyRaffle.sol#L205-L251) uses a weak PRNG: "[winnerIndex = uint256(keccak256(bytes)(abi.encodePacked(msg.sender,block.timestamp,block.difficulty))) % players.length](src/PuppyRaffle.sol#L213-L217)" 

src/PuppyRaffle.sol#L205-L251


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-2
[PuppyRaffle.withdrawFees()](src/PuppyRaffle.sol#L254-L263) uses a dangerous strict equality:
	- [require(bool,string)(address(this).balance == uint256(totalFees),PuppyRaffle: There are currently players active!)](src/PuppyRaffle.sol#L255-L258)

src/PuppyRaffle.sol#L254-L263


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-3
Reentrancy in [PuppyRaffle.refund(uint256)](src/PuppyRaffle.sol#L152-L177):
	External calls:
	- [address(msg.sender).sendValue(entranceFee)](src/PuppyRaffle.sol#L171)
	State variables written after the call(s):
	- [players[playerIndex] = address(0)](src/PuppyRaffle.sol#L175)
	[PuppyRaffle.players](src/PuppyRaffle.sol#L35) can be used in cross function reentrancies:
	- [PuppyRaffle.enterRaffle(address[])](src/PuppyRaffle.sol#L102-L148)
	- [PuppyRaffle.getActivePlayerIndex(address)](src/PuppyRaffle.sol#L184-L197)
	- [PuppyRaffle.players](src/PuppyRaffle.sol#L35)
	- [PuppyRaffle.refund(uint256)](src/PuppyRaffle.sol#L152-L177)
	- [PuppyRaffle.selectWinner()](src/PuppyRaffle.sol#L205-L251)

src/PuppyRaffle.sol#L152-L177


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-4
[PuppyRaffle.changeFeeAddress(address).newFeeAddress](src/PuppyRaffle.sol#L267) lacks a zero-check on :
		- [feeAddress = newFeeAddress](src/PuppyRaffle.sol#L268)

src/PuppyRaffle.sol#L267


 - [ ] ID-5
[PuppyRaffle.constructor(uint256,address,uint256)._feeAddress](src/PuppyRaffle.sol#L81) lacks a zero-check on :
		- [feeAddress = _feeAddress](src/PuppyRaffle.sol#L85)

src/PuppyRaffle.sol#L81


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-6
Reentrancy in [PuppyRaffle.selectWinner()](src/PuppyRaffle.sol#L205-L251):
	External calls:
	- [(success) = winner.call{value: prizePool}()](src/PuppyRaffle.sol#L248)
	- [_safeMint(winner,tokenId)](src/PuppyRaffle.sol#L250)
		- [returndata = to.functionCall(abi.encodeWithSelector(IERC721Receiver(to).onERC721Received.selector,_msgSender(),from,tokenId,_data),ERC721: transfer to non ERC721Receiver implementer)](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L441-L447)
		- [(success,returndata) = target.call{value: value}(data)](lib/openzeppelin-contracts/contracts/utils/Address.sol#L119)
	External calls sending eth:
	- [(success) = winner.call{value: prizePool}()](src/PuppyRaffle.sol#L248)
	- [_safeMint(winner,tokenId)](src/PuppyRaffle.sol#L250)
		- [(success,returndata) = target.call{value: value}(data)](lib/openzeppelin-contracts/contracts/utils/Address.sol#L119)
	Event emitted after the call(s):
	- [Transfer(address(0),to,tokenId)](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L343)
		- [_safeMint(winner,tokenId)](src/PuppyRaffle.sol#L250)

src/PuppyRaffle.sol#L205-L251


 - [ ] ID-7
Reentrancy in [PuppyRaffle.refund(uint256)](src/PuppyRaffle.sol#L152-L177):
	External calls:
	- [address(msg.sender).sendValue(entranceFee)](src/PuppyRaffle.sol#L171)
	Event emitted after the call(s):
	- [RaffleRefunded(playerAddress)](src/PuppyRaffle.sol#L176)

src/PuppyRaffle.sol#L152-L177


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-8
[PuppyRaffle.selectWinner()](src/PuppyRaffle.sol#L205-L251) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= raffleStartTime + raffleDuration,PuppyRaffle: Raffle not over)](src/PuppyRaffle.sol#L207-L210)

src/PuppyRaffle.sol#L205-L251


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-9
Different versions of Solidity are used:
	- Version used: ['>=0.6.0', '>=0.6.0<0.8.0', '>=0.6.2<0.8.0', '^0.7.6']
	- [>=0.6.0](lib/base64/base64.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/access/Ownable.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/introspection/ERC165.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/introspection/IERC165.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/math/SafeMath.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/utils/Context.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/utils/EnumerableMap.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/utils/EnumerableSet.sol#L3)
	- [>=0.6.0<0.8.0](lib/openzeppelin-contracts/contracts/utils/Strings.sol#L3)
	- [>=0.6.2<0.8.0](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#L3)
	- [>=0.6.2<0.8.0](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Enumerable.sol#L3)
	- [>=0.6.2<0.8.0](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Metadata.sol#L3)
	- [>=0.6.2<0.8.0](lib/openzeppelin-contracts/contracts/utils/Address.sol#L3)
	- [^0.7.6](src/PuppyRaffle.sol#L2)

lib/base64/base64.sol#L3


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-10
[PuppyRaffle._isActivePlayer()](src/PuppyRaffle.sol#L273-L280) is never used and should be removed

src/PuppyRaffle.sol#L273-L280


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-11
solc-0.7.6 is not recommended for deployment

 - [ ] ID-12
Pragma version[^0.7.6](src/PuppyRaffle.sol#L2) allows old versions

src/PuppyRaffle.sol#L2


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-13
Low level call in [PuppyRaffle.withdrawFees()](src/PuppyRaffle.sol#L254-L263):
	- [(success) = feeAddress.call{value: feesToWithdraw}()](src/PuppyRaffle.sol#L261)

src/PuppyRaffle.sol#L254-L263


 - [ ] ID-14
Low level call in [PuppyRaffle.selectWinner()](src/PuppyRaffle.sol#L205-L251):
	- [(success) = winner.call{value: prizePool}()](src/PuppyRaffle.sol#L248)

src/PuppyRaffle.sol#L205-L251


## cache-array-length
Impact: Optimization
Confidence: High
 - [ ] ID-15
Loop condition [i < players.length](src/PuppyRaffle.sol#L187) should use cached array length instead of referencing `length` member of the storage array.
 
src/PuppyRaffle.sol#L187


 - [ ] ID-16
Loop condition [i < players.length](src/PuppyRaffle.sol#L274) should use cached array length instead of referencing `length` member of the storage array.
 
src/PuppyRaffle.sol#L274


 - [ ] ID-17
Loop condition [j < players.length](src/PuppyRaffle.sol#L129) should use cached array length instead of referencing `length` member of the storage array.
 
src/PuppyRaffle.sol#L129


## constable-states
Impact: Optimization
Confidence: High
 - [ ] ID-18
[PuppyRaffle.commonImageUri](src/PuppyRaffle.sol#L54-L55) should be constant 

src/PuppyRaffle.sol#L54-L55


 - [ ] ID-19
[PuppyRaffle.raffleId](src/PuppyRaffle.sol#L51) should be constant 

src/PuppyRaffle.sol#L51


 - [ ] ID-20
[PuppyRaffle.legendaryImageUri](src/PuppyRaffle.sol#L66-L67) should be constant 

src/PuppyRaffle.sol#L66-L67


 - [ ] ID-21
[PuppyRaffle.rareImageUri](src/PuppyRaffle.sol#L60-L61) should be constant 

src/PuppyRaffle.sol#L60-L61


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-22
[PuppyRaffle.raffleDuration](src/PuppyRaffle.sol#L36) should be immutable 

src/PuppyRaffle.sol#L36


