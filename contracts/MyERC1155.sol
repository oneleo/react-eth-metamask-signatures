// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// If using Hardhat, you need to import the package through the command "pnpm install @openzeppelin/contracts".
// 如果使用 Hardhat 需透過 pnpm install @openzeppelin/contracts 指令來匯入套件
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/utils/Base64.sol";

// If using Remix, you can directly import the package through the GitHub URL.
// Remix website: https://remix.ethereum.org/
// 如果使用 Remix 可直接透過 GitHub 網址來匯入套件
// Remix 網站：https://remix.ethereum.org/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol";

contract MyERC1155 is ERC1155 {
    constructor(
        string memory _name,
        string memory _description,
        string memory _properties,
        uint256 _tokenId
    ) ERC1155(formatTokenURI(_name, _description, _properties, _tokenId)) {
        // Mint 1 NFT during contract deployment
        // Note: If minting 2 or more, it will be considered as Tokens.
        // 部署合約時鑄造 1 張 NFT
        // 註：若鑄造 2 張以上則為 Token
        _mint(msg.sender, _tokenId, 1, "");
    }

    // Save the NFT original image in Base64 format on the blockchain
    // You can refer to online SVG image to Base64 converter: https://www.svgviewer.dev/
    // Also refer to the online Base64 decoder: https://www.base64decode.org/
    // 將 NFT 原圖轉成 Base64 格式後保存於區塊鏈上
    // 可參考 SVG 圖檔轉成 Base64 線上編輯網站：https://www.svgviewer.dev/
    // 及參考 Base64 線上解譯網站：https://www.base64decode.org/
    function getSvg(uint256 tokenId) public pure returns (string memory) {
        string
            memory svgA = "<svg id='Capa_1' enable-background='new 0 0 511.99 511.99' height='512' viewBox='0 0 511.99 511.99' width='512' xmlns='http://www.w3.org/2000/svg'><g><text style='white-space:pre' x='50.0' y='150.0' fill='#000' font-family='Garamond' font-size='50'>#";
        string
            memory svgB = "</text><path d='m511.99 120.995c0-24.813-20.186-45-45-45h-421.99c-24.813 0-45 20.187-45 45v270c0 24.814 20.187 45 45 45h421.99c24.814 0 45-20.186 45-45zm-466.99-15h421.99c8.271 0 15 6.729 15 15v35h-451.99v-35c0-8.271 6.729-15 15-15zm421.99 300h-421.99c-8.271 0-15-6.728-15-15v-205h451.99v205c0 8.272-6.729 15-15 15z'/><path d='m198.314 226.296c-4.75 0-8.55 1.52-9.69 5.51l-26.41 97.472-26.601-97.472c-1.14-3.99-4.939-5.51-9.69-5.51-8.17 0-19 5.13-19 12.16 0 .569.19 1.33.38 2.09l35.531 115.901c2.09 6.65 10.64 9.88 19.38 9.88s17.29-3.229 19.38-9.88l35.341-115.901c.189-.76.38-1.521.38-2.09-.001-7.03-10.831-12.16-19.001-12.16z'/><path d='m257.4 226.296c-7.41 0-14.82 2.66-14.82 8.93v120.842c0 6.08 7.41 9.12 14.82 9.12s14.82-3.04 14.82-9.12v-120.843c.001-6.269-7.41-8.929-14.82-8.929z'/><path d='m402.18 269.996c0-31.92-19.76-43.7-44.84-43.7h-39.33c-6.65 0-11.021 4.18-11.021 8.93v120.842c0 6.08 7.41 9.12 14.82 9.12s14.82-3.04 14.82-9.12v-41.04h18.811c26.221 0 46.74-12.16 46.74-44.081zm-29.641 3.231c0 12.92-6.459 19-17.1 19h-18.811v-40.091h18.811c10.641 0 17.1 6.08 17.1 19.001z'/></g></svg>";
        return string(abi.encodePacked(svgA, uint2str(tokenId), svgB));
    }

    function formatTokenURI(
        string memory _name,
        string memory _description,
        string memory _properties,
        uint256 _tokenId
    ) public pure returns (string memory) {
        // Set the _uri with the original image data to comply with OpenSea standards: https://docs.opensea.io/docs/metadata-standards#metadata-structure
        // During testing, you can use this JSON validation website: https://jsonformatter.curiousconcept.com/
        // 設置 _uri 圖檔原始資料以符合 OpenSea 標準：https://docs.opensea.io/docs/metadata-standards#metadata-structure
        // 在測試階段可使用此 JSON 驗證網站：https://jsonformatter.curiousconcept.com/
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        _name,
                        '",',
                        '"description": "',
                        _description,
                        '",',
                        '"image_data": "',
                        getSvg(_tokenId),
                        '",',
                        '"attributes": "',
                        _properties,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Convert integers to strings in the contract.
    // 在合約中將整數轉成字串
    function uint2str(
        uint256 _i
    ) public pure returns (string memory _uintAsString) {
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
}
