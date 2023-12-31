// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// If using Hardhat, you need to import the package through the command "pnpm install @openzeppelin/contracts".
// 如果使用 Hardhat 需透過 pnpm install @openzeppelin/contracts 指令來匯入套件。
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/utils/Base64.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// If using Remix, you can directly import the package through the GitHub URL.
// Remix website: https://remix.ethereum.org/
// 如果使用 Remix 可直接透過 GitHub 網址來匯入套件。
// Remix 網站：https://remix.ethereum.org/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Base64.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/math/SafeMath.sol";

contract MyERC1155 is ERC1155 {
    using SafeMath for uint256;

    address public author;
    string public constant name = "CHTTI"; // 這個 'name' 是 OpenSea 所需的值，主要用於顯示 NFT 智能合約的名稱
    string private constant _myERC1155Description = "## CHTTI Blockchain Class";
    string private constant _myERC1155Attributes = "";
    string private constant _myERC1155BackgroundColor = "1F65AC";
    string private constant _myERC1155ExternalUrl =
        "https://www.chtti.cht.com.tw/";
    uint256 private constant _myERC1155InitialSupply = 3;
    uint256 public constant price = 0.0001 ether; // 鑄造 NFT 的價格
    uint256 public constant tokenIdMax = 99; // 隨機產生 tokenId 的最大值
    uint256 public constant tokenIdMin = 1; // 隨機產生 tokenId 的最小值

    constructor()
        payable
        ERC1155(
            // Initialize the base URI.
            // 初始化基礎 URI。
            _formatTokenURI(
                name,
                _myERC1155Description,
                _myERC1155Attributes,
                _myERC1155BackgroundColor,
                _myERC1155ExternalUrl,
                uint256(0)
            )
        )
    {
        // Set the smart contract author.
        // 設置智能合約作者。
        author = msg.sender;

        // If there is ether attached when deploying the contract, transfer it to the issuer.
        // 如果部署合約時有夾帶 ether，則轉給 issuer。
        payable(author).transfer(msg.value);

        // Mint 1 copy of each NFT upon contract deployment.
        // Note: If minting 2 or more, it will be considered as Tokens.
        // 部署合約時鑄造各 1 張 NFT。
        // 註：若鑄造 2 張以上則為 Token。
        for (uint256 i = 1; i <= _myERC1155InitialSupply; i++) {
            _mint(msg.sender, i, 1, "");
        }
    }

    function uri(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        return
            _formatTokenURI(
                name,
                _myERC1155Description,
                _myERC1155Attributes,
                _myERC1155BackgroundColor,
                _myERC1155ExternalUrl,
                _tokenId
            );
    }

    function mint() external payable returns (uint256) {
        require(msg.value >= price, "Value must be greater than price.");
        // Transfer the minting fee to the NFT author.
        // 將鑄造費轉給 NFT 作者。
        (bool success, bytes memory result) = payable(author).call{
            value: price
        }("");
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
        // Refund any excess ether
        // 將多餘的 ether 退還。
        if (msg.value > price) {
            (success, result) = payable(msg.sender).call{
                value: msg.value.sub(price)
            }("");
            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }
        // The random number generated by PreRandao will be updated every Slot (12 seconds)
        // 使用 PreRandao 建立的隨機數，每個 Slot（12 秒）會更新一次。
        uint256 random = (
            uint256(keccak256(abi.encodePacked(block.prevrandao)))
                .mod(tokenIdMax.sub(tokenIdMin).add(1))
                .add(tokenIdMin)
        );
        _mint(msg.sender, random, 1, "");
        return random;
    }

    // Save the NFT original image in Base64 format on the blockchain.
    // You can refer to online SVG image to Base64 converter: https://www.svgviewer.dev/
    // Also refer to the online Base64 decoder: https://www.base64decode.org/
    // 將 NFT 原圖轉成 Base64 格式後保存於區塊鏈上。
    // 可參考 SVG 圖檔轉成 Base64 線上編輯網站：https://www.svgviewer.dev/
    // 及參考 Base64 線上解譯網站：https://www.base64decode.org/
    function _getSvg(
        string memory _name,
        uint256 _tokenId
    ) internal pure returns (string memory) {
        string
            memory text1 = "<text x='35' y='86' font-family='Garamond' font-size='16'>";
        string
            memory text2 = " VIP</text><text x='15' y='100' font-family='Garamond' font-size='10'>#";
        string memory text3 = "</text></svg>";
        string
            memory svgA = "<svg viewBox='0 0 128 128' xmlns='http://www.w3.org/2000/svg'><rect fill='#ffcd3c' height='76.504' rx='7.694' width='117.9' x='6.767' y='27.232'/><path d='M6.767 39.75h117.9v16.583H6.767z' fill='#0d1b5e'/><g fill='#fceac3'><rect height='8.174' rx='3.297' width='20.422' x='92.512' y='88.159'/><rect height='9.742' rx='1.615' width='48.718' x='16.999' y='63'/></g>";
        string
            memory svgB = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 128 128'><path d='M116.973 25.482H14.461a9.455 9.455 0 0 0-9.444 9.444v61.116a9.454 9.454 0 0 0 9.444 9.443h102.512a9.454 9.454 0 0 0 9.444-9.443V34.926a9.455 9.455 0 0 0-9.444-9.444Zm5.944 70.56a5.951 5.951 0 0 1-5.944 5.943H14.461a5.951 5.951 0 0 1-5.944-5.943V56.677h114.4Zm0-42.865H8.517V42.5h114.4Zm0-14.177H8.517v-4.074a5.951 5.951 0 0 1 5.944-5.944h102.512a5.951 5.951 0 0 1 5.944 5.944Z'/><path d='M95.81 98.083h13.827a5.053 5.053 0 0 0 5.048-5.047v-1.579a5.054 5.054 0 0 0-5.048-5.048H95.81a5.054 5.054 0 0 0-5.048 5.048v1.579a5.053 5.053 0 0 0 5.048 5.047Zm-1.548-6.626a1.55 1.55 0 0 1 1.548-1.548h13.827a1.55 1.55 0 0 1 1.548 1.548v1.579a1.55 1.55 0 0 1-1.548 1.547H95.81a1.55 1.55 0 0 1-1.548-1.547ZM18.614 74.492H64.1a3.369 3.369 0 0 0 3.365-3.365v-6.513A3.368 3.368 0 0 0 64.1 61.25H18.614a3.368 3.368 0 0 0-3.365 3.364v6.513a3.369 3.369 0 0 0 3.365 3.365Zm.135-9.742h45.218v6.242H18.749Z'/>";

        return
            _tokenId == 1
                ? string(
                    abi.encodePacked(
                        svgA,
                        text1,
                        _name,
                        text2,
                        _uint2str(_tokenId),
                        text3
                    )
                )
                : string(
                    abi.encodePacked(
                        svgB,
                        text1,
                        _name,
                        text2,
                        _uint2str(_tokenId),
                        text3
                    )
                );
    }

    function _formatTokenURI(
        string memory _name,
        string memory _description,
        string memory _attributes,
        string memory _backgroundColor,
        string memory _externalUrl,
        uint256 _tokenId
    ) internal pure returns (string memory) {
        // Set the _uri with the original image data to comply with OpenSea standards: https://docs.opensea.io/docs/metadata-standards#metadata-structure
        // During testing, you can use this JSON validation website: https://jsonformatter.curiousconcept.com/
        // 設置 _uri 圖檔原始資料以符合 OpenSea 標準：https://docs.opensea.io/docs/metadata-standards#metadata-structure
        // 在測試階段可使用此 JSON 驗證網站：https://jsonformatter.curiousconcept.com/
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        // Name of the item.
                        // 項目的名稱。
                        '{"name": "',
                        _name,
                        '",',
                        // A human readable description of the item. Markdown is supported.
                        // 對項目的人類可讀描述。支援 Markdown 格式。
                        '"description": "',
                        _description,
                        '",',
                        // Raw SVG image data, if you want to generate images on the fly. Only use this if you're not including the image parameter.
                        // 原始 SVG 圖像資料，如果您希望動態生成圖像。僅在不包含 image 參數時使用。
                        '"image_data": "',
                        _getSvg(_name, _tokenId),
                        '",',
                        // This is the URL to the image of the item. Can be just about any type of image (including SVGs, which will be cached into PNGs by OpenSea), and can be IPFS URLs or paths. We recommend using a 350 x 350 image.
                        // 這是項目圖像的 URL。可以是任何類型的圖像（包括 SVG，OpenSea 將將其轉換為 PNG 並進行快取），並且可以是 IPFS URL 或路徑。建議使用 350 x 350 的圖像大小。
                        // '"image": "',
                        // _image, // Example: "ipfs://QmS4dzwJi85Et3ox2UPFEDMFvwx9bADThYSr9LKXXvWYEX"
                        // '",',
                        // Background color of the item on OpenSea. Must be a six-character hexadecimal without a pre-pended #.
                        // 在 OpenSea 上顯示項目的背景顏色。必須是六個字符的十六進制值，不包含 #。
                        '"background_color": "',
                        _backgroundColor,
                        '",',
                        // This is the URL that will appear below the asset's image on OpenSea and will allow users to leave OpenSea and view the item on your site.
                        // 這是在 OpenSea 上項目圖像下方顯示的 URL，用戶可以通過此 URL 離開 OpenSea，並在您的網站上查看該項目。
                        '"external_url": "',
                        _externalUrl,
                        '",',
                        // A URL to a YouTube video.
                        // 一個指向 YouTube 影片的 URL。
                        // '"youtube_url": "',
                        // _youtubeUrl,
                        // '",',
                        // These are the attributes for the item, which will show up on the OpenSea page for the item.
                        // 這些是項目的屬性，在 OpenSea 頁面上會顯示出來。
                        '"attributes": "',
                        _attributes,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Convert integers to strings in the contract.
    // 在合約中將整數轉成字串。
    function _uint2str(
        uint256 _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // If msg.data is present and there is no corresponding function, the fallback() function is called.
    // 如果 msg.data 有值且沒有對應的函數，將呼叫 fallback() 函數。
    fallback() external payable {
        payable(author).transfer(msg.value);
    }

    // When this contract receives Ether and msg.data is empty, the receive() function is called.
    // 當 this 合約收到以太幣且 msg.data 為空時，將呼叫 receive() 函數。
    receive() external payable {
        payable(author).transfer(msg.value);
    }
}
