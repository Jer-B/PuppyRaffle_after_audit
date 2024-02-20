// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6; // @original
//pragma solidity ^0.8.24; // @audit add
//@audit pragma outdated. Mathematics could be outdated. overflow/underflow attack
// Can't use error and revert statements in the chosen version. Needs to be at least 0.8.0.
//@audit it will also have an effect with the compatibility of the base64 library.

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Base64} from "lib/base64/base64.sol";

/// @title PuppyRaffle
/// @author PuppyLoveDAO
/// @notice This project is to enter a raffle to win a cute dog NFT. The protocol should do the following:
/// 1. Call the `enterRaffle` function with the following parameters:
///    1. `address[] participants`: A list of addresses that enter. You can use this to enter yourself multiple times, or yourself and a group of your friends.
/// 2. Duplicate addresses are not allowed
/// 3. Users are allowed to get a refund of their ticket & `value` if they call the `refund` function
/// 4. Every X seconds, the raffle will be able to draw a winner and be minted a random puppy
/// 5. The owner of the protocol will set a feeAddress to take a cut of the `value`, and the rest of the funds will be sent to the winner of the puppy.

//@audit example error and revert statement instead of a require statement
// error PuppyRaffle__MustSendEnoughToEnterRaffle(
//     uint256 value,
//     uint256 entranceFeeRequired
// );
// error PuppyRaffle__DuplicatePlayer();

contract PuppyRaffle is ERC721, Ownable {
    using Address for address payable;

    uint256 public immutable entranceFee;

    address[] public players;
    uint256 public raffleDuration;
    uint256 public raffleStartTime;
    address public previousWinner;

    // We do some storage packing to save gas
    address public feeAddress;
    uint64 public totalFees = 0;

    // mappings to keep track of token traits
    mapping(uint256 => uint256) public tokenIdToRarity;
    mapping(uint256 => string) public rarityToUri;
    mapping(uint256 => string) public rarityToName;

    // @audit mapping to check participants and raffle id
    mapping(address => uint256) public addressToParticipantIndex;
    uint256 public raffleId = 0;

    // Stats for the common puppy (pug)
    string private commonImageUri =
        "ipfs://QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8";
    uint256 public constant COMMON_RARITY = 70;
    string private constant COMMON = "common";

    // Stats for the rare puppy (st. bernard)
    string private rareImageUri =
        "ipfs://QmUPjADFGEKmfohdTaNcWhp7VGk26h5jXDA7v3VtTnTLcW";
    uint256 public constant RARE_RARITY = 25;
    string private constant RARE = "rare";

    // Stats for the legendary puppy (shiba inu)
    string private legendaryImageUri =
        "ipfs://QmYx6GsYAKnNzZ9A6NvEKV9nf1VaDzJrqDR23Y8YSkebLU";
    uint256 public constant LEGENDARY_RARITY = 5;
    string private constant LEGENDARY = "legendary";

    // Events

    // @audit event indexes are missing
    // @audit indexes should be added to the events to make it easier to filter the events
    // example: event RaffleEnter(address[] newPlayers) indexed;
    event RaffleEnter(address[] newPlayers);
    event RaffleRefunded(address player);
    event FeeAddressChanged(address newFeeAddress);

    /// @param _entranceFee the cost in wei to enter the raffle
    /// @param _feeAddress the address to send the fees to
    /// @param _raffleDuration the duration in seconds of the raffle
    constructor(
        uint256 _entranceFee,
        address _feeAddress,
        uint256 _raffleDuration
    ) ERC721("Puppy Raffle", "PR") {
        entranceFee = _entranceFee;
        feeAddress = _feeAddress;
        raffleDuration = _raffleDuration;
        raffleStartTime = block.timestamp;

        rarityToUri[COMMON_RARITY] = commonImageUri;
        rarityToUri[RARE_RARITY] = rareImageUri;
        rarityToUri[LEGENDARY_RARITY] = legendaryImageUri;

        rarityToName[COMMON_RARITY] = COMMON;
        rarityToName[RARE_RARITY] = RARE;
        rarityToName[LEGENDARY_RARITY] = LEGENDARY;
    }

    /// @notice this is how players enter the raffle
    /// @notice they have to pay the entrance fee * the number of players
    /// @notice duplicate entrants are not allowed
    /// @param newPlayers the list of players to enter the raffle
    function enterRaffle(address[] memory newPlayers) public payable {
        // @audit i - extra gas spent on the require. can be a if statement

        // @audit q - what if the length of newPlayers is 0? can enter for free ?
        // @audit q - DOS attack what if the length of newPlayers is 100 players ? 101th will be required to be able to pay 100 eth ?
        // @audit q - what if the first player choose to get refund after other players entered. -> free entry and compensated exit ?
        require(
            msg.value == entranceFee * newPlayers.length,
            "PuppyRaffle: Must send enough to enter raffle"
        );

        // @audit change the require in an if condition
        // if (msg.value != entranceFee * newPlayers.length) {
        //     revert PuppyRaffle__MustSendEnoughToEnterRaffle({
        //         value: msg.value,
        //         entranceFeerequired: entranceFee * newPlayers.length
        //     });
        // }

        for (uint256 i = 0; i < newPlayers.length; i++) {
            players.push(newPlayers[i]);
            addressToParticipantIndex[newPlayers[i]] = raffleId;
        }

        // Check for duplicates
        for (uint256 i = 0; i < players.length - 1; i++) {
            // @audit - need to change the way of using foor loops to check for duplicates. can lead to a DOS attack and blowing up the gas floor which will lead to unusable contract for users. too expensive.
            for (uint256 j = i + 1; j < players.length; j++) {
                require(
                    players[i] != players[j],
                    "PuppyRaffle: Duplicate player"
                );
            }
        }

        // @audit check for duplicates based on a raffle ID and a mapping of participants
        // for (uint256 i = 0; i < players.length - 1; i++) {
        //     require(
        //         addressToParticipantIndex[newPlayers[i]] != raffleId,
        //         "PuppyRaffle: Duplicate player"
        //     );

        //     // @audit or use error / revert statement if pragma version is up to date
        //     // if(addressToParticipantIndex[newPlayers[i]] != raffleId){
        //     //     revert PuppyRaffle__DuplicatePlayer();
        // }
    }

    /// @param playerIndex the index of the player to refund. You can find it externally by calling `getActivePlayerIndex`
    /// @dev This function will allow there to be blank spots in the array
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

        // @audit the 101th player is refunded 1 eth but had to pay 100 eth to enter
        // @audit first player get paid for leaving, and starting from the second player, players doesnt get refunded what they paid

        // @audit changing the event and state change place to avoid a re entrancy attack
        // emit RaffleRefunded(playerAddress);
        // players[playerIndex] = address(0);

        payable(msg.sender).sendValue(entranceFee);

        // @audit reentrancy attack. event should be emitted before the state is changed and before the transaction is made
        // @audit the state change should also be done before the transaction to get the refunds starts
        players[playerIndex] = address(0);
        emit RaffleRefunded(playerAddress);
    }

    /// @notice a way to get the index in the array
    /// @param player the address of a player in the raffle
    /// @return the index of the player in the array, if they are not active, it returns 0

    /// @return the index of the player in the array, if they are not active, it returns the max uint
    function getActivePlayerIndex(
        address player
    ) public view returns (uint256) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                // @audit q - what if the active player is at index 0? Player won`t be considered as active.
                return i;
            }
        }

        // @audit if there is no active player at index 0, return the max uint
        // return 0;
        return type(uint256).max; // Sentinel value indicating not found
    }

    /// @notice this function will select a winner and mint a puppy
    /// @notice there must be at least 4 players, and the duration has occurred
    /// @notice the previous winner is stored in the previousWinner variable
    /// @dev we use a hash of on-chain data to generate the random numbers
    /// @dev we reset the active players array after the winner is selected
    /// @dev we send 80% of the funds to the winner, the other 20% goes to the feeAddress
    function selectWinner() external {
        // @audit should manage the state of the raffle by using enum instead of conditionals
        require(
            block.timestamp >= raffleStartTime + raffleDuration,
            "PuppyRaffle: Raffle not over"
        );
        require(players.length >= 4, "PuppyRaffle: Need at least 4 players");
        // @audit the winner can be guessed in advance
        uint256 winnerIndex = uint256(
            keccak256(
                abi.encodePacked(msg.sender, block.timestamp, block.difficulty)
            )
        ) % players.length;
        address winner = players[winnerIndex];
        uint256 totalAmountCollected = players.length * entranceFee;
        uint256 prizePool = (totalAmountCollected * 80) / 100;
        uint256 fee = (totalAmountCollected * 20) / 100;

        // @audit overflow + unsafe casting of uint256 to uint64 and precision loss
        totalFees = totalFees + uint64(fee);

        // @audit where the tokenId is incremented to avoid the next winner gets to reused the same tokenId that the previous winner got?
        uint256 tokenId = totalSupply();

        // We use a different RNG calculate from the winnerIndex to determine rarity
        // @audit the rarity can be guessed in advance
        uint256 rarity = uint256(
            keccak256(abi.encodePacked(msg.sender, block.difficulty))
        ) % 100;
        if (rarity <= COMMON_RARITY) {
            tokenIdToRarity[tokenId] = COMMON_RARITY;
        } else if (rarity <= COMMON_RARITY + RARE_RARITY) {
            tokenIdToRarity[tokenId] = RARE_RARITY;
        } else {
            tokenIdToRarity[tokenId] = LEGENDARY_RARITY;
        }

        delete players;
        // @audit should manage the state of the raffle by using enum instead to set the raffle as "ended"
        raffleStartTime = block.timestamp;
        previousWinner = winner;

        // @audit reentrancy attack. safemint should be called before the transaction to send the prize pool to the winner
        (bool success, ) = winner.call{value: prizePool}("");
        require(success, "PuppyRaffle: Failed to send prize pool to winner");
        _safeMint(winner, tokenId); // @audit to change place of the safemint call to avoid reentrancy
    }

    /// @notice this function will withdraw the fees to the feeAddress
    function withdrawFees() external {
        require(
            address(this).balance == uint256(totalFees),
            "PuppyRaffle: There are currently players active!"
        );
        uint256 feesToWithdraw = totalFees;
        totalFees = 0;
        (bool success, ) = feeAddress.call{value: feesToWithdraw}("");
        require(success, "PuppyRaffle: Failed to withdraw fees");
    }

    /// @notice only the owner of the contract can change the feeAddress
    /// @param newFeeAddress the new address to send fees to
    function changeFeeAddress(address newFeeAddress) external onlyOwner {
        feeAddress = newFeeAddress;
        emit FeeAddressChanged(newFeeAddress);
    }

    /// @notice this function will return true if the msg.sender is an active player
    function _isActivePlayer() internal view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /// @notice this could be a constant variable
    function _baseURI() internal pure returns (string memory) {
        return "data:application/json;base64,";
    }

    /// @notice this function will return the URI for the token
    /// @param tokenId the Id of the NFT
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "PuppyRaffle: URI query for nonexistent token"
        );

        uint256 rarity = tokenIdToRarity[tokenId];
        string memory imageURI = rarityToUri[rarity];
        string memory rareName = rarityToName[rarity];

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An adorable puppy!", ',
                                '"attributes": [{"trait_type": "rarity", "value": ',
                                rareName,
                                '}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
