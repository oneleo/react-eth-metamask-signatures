// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract SignatureDemo {
    address public owner;
    mapping(address => uint256) public nonces;

    // If msg.data is present and there is no corresponding function, the fallback() function is called.
    // 如果 msg.data 有值且沒有對應的函數，將呼叫 fallback() 函數。
    fallback() external payable {}

    // When this contract receives Ether and msg.data is empty, the receive() function is called.
    // 當 this 合約收到以太幣且 msg.data 為空時，將呼叫 receive() 函數。
    receive() external payable {}

    // // When this contract is deployed, the constructor() function is executed.
    // 當 this 合約被部署時，執行 constructor() 函數。
    constructor() payable {
        owner = msg.sender;
    }

    function executeWithoutNonce(
        bytes calldata _data, // _data = abi.encode(address signer, address to, uint256 nonce, uint256 amount, bytes memory callData);
        bytes calldata _signature
    ) external payable {
        // Note: In practice, the owner must be set for this contract. Only the contract owner can execute this function.
        // Also, the _data parameter needs to include a field for the hash value of this function, limiting the use of this _data to calling this function only.
        // 注意事項：在實務上，必須為此合約設置擁有者。只有合約擁有者才能執行此函數；
        // 此外，_data 參數需要新增一個雜湊值欄位，用於限制該 _data 只能用於呼叫此函數。
        (
            // bytes32 executeWithoutNonceHash
            address signer,
            address to, // uint256 nonce,
            ,
            uint256 value,
            bytes memory callData
        ) = abi.decode(_data, (address, address, uint256, uint256, bytes));

        // Unless it is the contract owner, the Value limit is set not to exceed 0.01 ether.
        // 除非是合約擁有者，否則 Value 限制為不超過 0.01 ether。
        require(
            owner == msg.sender || value <= 0.01 ether,
            "The withdrawal amount exceeds 0.01 ether."
        );

        // Confirm that _data is signed by the signer.
        // 確認 _data 是由 signer 親簽的。
        checkSignature(signer, _data, _signature);

        // Proceed with the transaction operation based on the values of to, value, and callData.
        // If you want to transfer ETH (callData.length == 0), you need to transfer an equal amount of ETH to this contract before or at the same time as calling the executeWithoutNonce() or executeWithNonce() functions.
        // If you want to transfer USDT (callData.length != 0), you need to transfer an equal amount of ERC20 tokens to this contract before calling the executeWithoutNonce() or executeWithNonce() functions.
        // 根據解析出來的 to、value、callData 值來進行後續的交易操作。
        // 如果您要轉送 ETH（callData.length == 0），則您需在呼叫 executeWithoutNonce() 或 executeWithNonce() 函數之前或同時，轉入與 value 等量的 ETH 給 this 合約。
        // 如果您要轉送 USDT（callData.length != 0），則您需在呼叫 executeWithoutNonce() 或 executeWithNonce() 函數之前，轉入與 value 等量的等量的 ERC20 給 this 合約。
        (bool success, bytes memory result) = payable(to).call{value: value}(
            callData
        );

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function executeWithNonce(
        bytes calldata _data,
        bytes calldata _signature
    ) external payable {
        (
            address signer,
            address to,
            uint256 nonce,
            uint256 value,
            bytes memory callData
        ) = abi.decode(_data, (address, address, uint256, uint256, bytes));

        // Unless it is the contract owner, the Value limit is set not to exceed 0.01 ether.
        // 除非是合約擁有者，否則 Value 限制為不超過 0.01 ether。
        require(
            msg.sender == owner || value <= 0.01 ether,
            "The withdrawal amount exceeds 0.01 ether."
        );

        // Verify that the Nonce value is correct.
        // 確定 Nonce 值正確。
        require(nonces[signer] == nonce, "Invalid nonce");
        nonces[signer]++;

        checkSignature(signer, _data, _signature);

        (bool success, bytes memory result) = payable(to).call{value: value}(
            callData
        );

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function checkSignature(
        address _signer,
        bytes memory _data,
        bytes memory _signature
    ) public pure {
        require(_signature.length >= 65, "Signatures data too short");
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 hash = keccak256(_data);

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := and(mload(add(_signature, 0x41)), 0xff)
        }

        bytes32 messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address recoveredSigner = ecrecover(messageHash, v, r, s);

        require(
            recoveredSigner == _signer,
            "Invalid contract signature provided"
        );
    }

    // input example: ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
    function transferBatch(address[] calldata _to) external payable {
        // Only the contract owner can initiate the transfer.
        // 只有合約擁有者可以轉帳
        require(msg.sender == owner, "Only contract owner can transfer");
        for (uint256 i = 0; i < _to.length; i++) {
            (bool success, bytes memory result) = payable(_to[i]).call{
                value: 0.01 ether
            }("");

            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }
    }
}
