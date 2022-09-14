// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.4;

  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "./IWhitelist.sol";

/**
 * functions included :
 * https://docs.openzeppelin.com/contracts/2.x/api/token/erc721
 */
  
contract CryptoDevs is ERC721Enumerable, Ownable {
  /**
 * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
 * token will be the concatenation of the `baseURI` and the `tokenId`.
 */
  string _baseTokenURI;

  // price of one CryptoDev NFT
  uint256 public _price = 0.01 ether;

  //paused the contract in case of emergency
  bool public _paused;

  // max number of cryptodev
  uint256 public maxTokenIds = 20;

  // total number of tokenIds minted
  uint256 public tokenIds;

  // Whitelist contrac instance
  IWhitelist whitelist;

  // boolean to keep track of whether presale started or not\
  bool public presaleStarted;

  // timstamp for when presale would end
  uint256 public presaleEnded;

  modifier onlyWhenNotPause {
    require(!_paused, "Contract currently paused");
    _;
  }

  /**
   * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
   * name in our case is `Crypto Devs` and symbol is `CD`.
   * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.
   * It also initializes an instance of whitelist interface.
   */
  constructor (string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
    _baseTokenURI = baseURI;
    whitelist = IWhitelist(whitelistContract);
  }

  /**
  * @dev startPresale starts a presale for the whitelisted addresses
    */  
  function startPresale() public onlyOwner {
    presaleStarted = true;
    // Set presaleEnded time as current timestamp + 5 minutes
    // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
    presaleEnded = block.timestamp + 5 minutes;
  }
  /**
   * @dev presaleMint allows a user to mint one NFT per transaction during the presale.
   */
  function presaleMint() public payable onlyWhenNotPause {
    require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
    require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maximun Crypto Devs supply");
    require(msg.value >= _price, "Ether sent is not correct");
    tokenIds += 1;
    _safeMint(msg.sender, tokenIds);
  }

  /**
  * @dev mint allows a user to mint 1 NFT per transaction after the presale has ended.
  */
  function mint() public payable onlyWhenNotPause {
    require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
    require(tokenIds < maxTokenIds, "Exceeded maximun Crypto Devs supply");
    require(msg.value >= _price, "Ether sent is not correct");
    tokenIds += 1;
    _safeMint(msg.sender, tokenIds);
  }

  /**
  * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
  * returned an empty string for the baseURI
  */
  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

  function setPaused(bool val) public onlyOwner {
    _paused = val;
  }

  /**
  * @dev withdraw sends all the ether in the contract
  * to the owner of the contract
  */
  function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent, ) = _owner.call{value: amount} ("");
    require(sent, "Failed to sent Ether");
  }    

  // Function to receive Ether. msg.data must be empty
  receive() external payable {}

  // Fallback function is called when msg.data is not empty
  fallback() external payable {}
}