// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/**
 * @title ERC721MeritocraticVotesUpgradeable
 * @dev ERC721 token with meritocratic voting power and soulbound properties.
 * Each token's vote can be influenced by multipliers based on attributes.
 * Tokens are soulbound and cannot be transferred after minting.
 */
contract ERC721MeritocraticVotesUpgradeable is
    Initializable,
    ERC721Upgradeable,
    VotesUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{
    struct Multiplier {
        string name;
        uint256 percentage; // Basis points: 10000 = 100%
    }

    mapping(uint256 => Multiplier[]) public tokenMultipliers;
    mapping(address => uint256[]) private _ownedTokens;

    uint256 public baseVotingPower;

    address public attestationStation;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @dev Initializes the contract with the given parameters.
     */
    function initialize(
        string memory name,
        string memory symbol,
        address _attestationStation,
        uint256 _baseVotingPower
    ) public initializer {
        __ERC721MeritocraticVotes_init(name, symbol, _attestationStation, _baseVotingPower);
    }
function _baseURI() internal view virtual override returns (string memory) {
    return "https://your-api-url.com/metadata/";
}

    function __ERC721MeritocraticVotes_init(
        string memory name,
        string memory symbol,
        address _attestationStation,
        uint256 _baseVotingPower
    ) internal onlyInitializing {
        __ERC721_init_unchained(name, symbol);
        __Votes_init_unchained();
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ERC721MeritocraticVotes_init_unchained(_attestationStation, _baseVotingPower);
    }

    function __ERC721MeritocraticVotes_init_unchained(
        address _attestationStation,
        uint256 _baseVotingPower
    ) internal onlyInitializing {
        attestationStation = _attestationStation;
        baseVotingPower = _baseVotingPower; // For example, 0.2 ether

        // Grant the deployer the MINTER_ROLE
        _grantRole(MINTER_ROLE, _msgSender());
    }

    /**
     * @dev Sets a multiplier attribute for a specific tokenId.
     * Example: setMultiplier(tokenId, "isBuilder", 2000) increases vote weight by 20%.
     */
    function setMultiplier(
        uint256 tokenId,
        string memory name,
        uint256 percentage
    ) public onlyOwner {
        tokenMultipliers[tokenId].push(Multiplier(name, percentage));
    }

    /**
     * @dev Calculates the voting units for a given account, considering multipliers.
     */
    function _getVotingUnits(address account)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        uint256 totalVotingPower = 0;
        uint256[] storage tokens = _ownedTokens[account];

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenId = tokens[i];
            uint256 tokenVotingPower = baseVotingPower;

            Multiplier[] memory multipliers = tokenMultipliers[tokenId];
            for (uint256 j = 0; j < multipliers.length; j++) {
                tokenVotingPower += (tokenVotingPower * multipliers[j].percentage) / 10000;
            }

            totalVotingPower += tokenVotingPower;
        }

        return totalVotingPower;
    }

    /**
     * @dev Prevents transfers by overriding the external transfer functions.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        revert("Tokens are soulbound and cannot be transferred");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        revert("Tokens are soulbound and cannot be transferred");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        revert("Tokens are soulbound and cannot be transferred");
    }

function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Overrides the _mint function to manage ownership enumeration.
     */
    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Overrides the _burn function to manage ownership enumeration.
     */
    function _burn(uint256 tokenId) internal virtual override {
        address owner = ownerOf(tokenId);
        super._burn(tokenId);
        _removeTokenFromOwnerEnumeration(owner, tokenId);
    }

    /**
     * @dev Adds a token to the owner's list of tokens.
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Removes a token from the owner's list of tokens.
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256[] storage tokens = _ownedTokens[from];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }
    }

    /**
     * @dev Prevents approval of tokens since they are soulbound.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        revert("Tokens are soulbound and cannot be transferred");
    }

    /**
     * @dev Prevents setting approval for all tokens.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        revert("Tokens are soulbound and cannot be transferred");
    }

    /**
     * @dev Mints a new token to the specified address. Only accounts with MINTER_ROLE can call this function.
     */
    function mint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
    }

    /**
     * @dev Allows the owner of a token to burn it.
     */
    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == _msgSender(), "Only the owner can burn the token");
        _burn(tokenId);
    }

    /**
     * @dev Supports interface detection, considering multiple inheritance.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
