// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract SignatureDemo {
    mapping(address => uint256) public nonces;

    function executeWithoutNonce(
        bytes memory _data, // _data = abi.encode(address signer, address to, uint256 nonce, uint256 amount, bytes memory callData);
        bytes memory _signature
    ) external payable {
        (
            address signer,
            address to, // uint256 nonce,
            ,
            uint256 value,
            bytes memory callData
        ) = abi.decode(_data, (address, address, uint256, uint256, bytes));

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

    // Signer (Remix Signer 0): 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // Private Key of Signer: 0x503f38a9c967ed597e47fe25643985f032b072db8075426a92110f82df48dfcb
    // Reference: https://github.com/ethereum/remix-project/blob/master/libs/remix-simulator/src/methods/accounts.ts
    // DataPack:
    // ↳ Signer: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // ↳ To (Remix Signer 1): 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // ↳ Nonce: 0 ~ 2
    // ↳ Amount: 10 * 10 ^ 18
    // ↳ CallData: 0x
    // Message (Nonce = 0): 0x0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000
    // Signature (Nonce = 0): 0x519ec7a7fd09e54cb230cc084c67a268ce71f95f9f33bd62141158b91e851bb745dbd5ea41e98a6a7c2219caac2a4205f80ba871a2d1af4330b447703ed31a581b
    // Message (Nonce = 1): 0x0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000
    // Signature (Nonce = 1): 0x361a08b739a9cdb6af573934a121e21549b4d20e51b779f0b9437332bdb794c244d214ca0b08cf0e0109094c3f07ce131b58fb40e746426f8fe80a610779053f1c
    // Message (Nonce = 2): 0x0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000
    // Signature (Nonce = 2): 0x588be60e4e80ed2ea8f8475a928c9054851cd92dfd74bc9ee882496c738116d50279dcf61625743695f919f84bea8e0313cabfcc263c642505b87f2d2e71b55f1c

    function executeWithNonce(
        bytes memory _data,
        bytes memory _signature
    ) external payable {
        (
            address signer,
            address to,
            uint256 nonce,
            uint256 value,
            bytes memory callData
        ) = abi.decode(_data, (address, address, uint256, uint256, bytes));

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
}
