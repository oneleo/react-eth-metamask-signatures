// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SignatureDemo {
    mapping(address => uint256) private _nonces;

    function execute(
        bytes memory _data, // _data = abi.encode(address signer, address to, uint256 nonce, uint256 amount, bytes memory callData);
        bytes memory _signature
    ) external {
        (address signer, , uint256 nonce, , ) = abi.decode(
            _data,
            (address, address, uint256, uint256, bytes)
        );

        // Verify that the Nonce value is correct.
        require(_nonces[signer] == nonce, "invalid nonce");
        _nonces[signer]++;

        // Confirm that _data is signed by the signer.
        checkSignature(signer, _data, _signature);

        // Proceed with the transaction operation based on the values of to, value, and callData.
        // …
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
