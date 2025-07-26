// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface MyDrawWinner {
    function add_accumulative_money(uint256 _accumulative_money) external;
}

contract SoulNFT {

    error Soulbound();

    MyDrawWinner public mydrawwinner;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    string public constant symbol = "SHN";

    string public constant name = "Soulbound Hashball NFT";

    mapping(uint256 => address) public ownerOf;

    mapping(address => uint256) public balanceOf;

    uint256 public nftindex;
    address public owner;
    address public receiver_nft_pool;
    address public receiver_ball_pool;
    uint256 public NFTprice;//price
    uint256 public constant MAXSUPPLY = 1000000;
    bool public start_mint;
    bool private initialized;
    string public _metadataURI;
    address public receiver_system;

    function initialize(address _owner) public{
        require(!initialized, "already initialized");
        initialized = true;
        owner = _owner;
        nftindex = 0;
        NFTprice = 6 * 10 ** 14;
        start_mint = false;
        _metadataURI = "https://variable-pink-nightingale.myfilebase.com/ipfs/QmW8SCUu65wVWTd6QVgUK5j1f8MG7aXiExKZgf33WxxW2i";
    }

    function set_mydraw_winner(address _draw_winner_address) public{
        require(msg.sender == owner, "not allow");
        mydrawwinner = MyDrawWinner(_draw_winner_address);
    }

    function set_nft_price(uint256 _nft_price) public{
        require(msg.sender == owner, "not allow");
        NFTprice = _nft_price;
    }

    function set_receiver(address _receiver_nft, address _receiver_ball, address _receiver_system) public{
        require(msg.sender == owner, "not allow");
        receiver_nft_pool = _receiver_nft;
        receiver_ball_pool = _receiver_ball;
        receiver_system = _receiver_system;
    }

    function set_start_mint(bool _true_false) public{
        require(msg.sender == owner, "not allow");
        start_mint = _true_false;
    }

    function set_metadataURI(string calldata _url) public{
        require(msg.sender == owner, "not allow");
        _metadataURI = _url;
    }

    function approve(address, uint256) public virtual {
        revert Soulbound();
    }

    function isApprovedForAll(address, address) public pure {
        revert Soulbound();
    }

    function getApproved(uint256) public pure {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public virtual {
        revert Soulbound();
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual {
        revert Soulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public virtual {
        revert Soulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual {
        revert Soulbound();
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    receive() external payable {}
    fallback() external payable {}

    function mint() public payable {
        require(start_mint, "not start");
        require(balanceOf[msg.sender] < 1, "already mint");
        require(1 + nftindex <= MAXSUPPLY, "Exceed max supply");
        nftindex = nftindex + 1;
        ownerOf[nftindex] = msg.sender;
        balanceOf[msg.sender] = 1;
        require(msg.value >= NFTprice, "not enough pay");
        (bool success_nft, ) = (receiver_nft_pool).call{value: msg.value*40/100}("");
        if(!success_nft){
            revert('call nft failed');
        }
        (bool success_ball, ) = (receiver_ball_pool).call{value: msg.value*40/100}("");
        if(!success_ball){
            revert('call ball failed');
        }
        (bool success_system, ) = (receiver_system).call{value: msg.value*20/100}("");
        if(!success_system){
            revert('call ball failed');
        }
        //add accumulative money
        mydrawwinner.add_accumulative_money(msg.value*40/100);

        emit Transfer(address(0), msg.sender, nftindex);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(tokenId <= nftindex, "tokenId exceed");        
        return _metadataURI;
    }

    function get_nft_info() public view returns(uint256, uint256, bool) {
        return (nftindex, NFTprice, start_mint);
    }
}
