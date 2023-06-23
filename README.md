# react-eth-metamask-signatures

- This repository is a fork of [react-eth-metamask-signatures](https://codesandbox.io/s/react-eth-metamask-signatures-ibuxj)

- Additionally, this repository has also been published on [codesandbox](https://codesandbox.io/s/react-eth-metamask-signatures-forked-mvvkxc)

## Starting the Web Application

```shell
% pnpm install
% FAST_REFRESH=false pnpm run start
```

![Sign & Verify Messages](./thumbnail.jpeg "Sign & Verify Messages")

## How to Use the Web Application

- You can generate the data packet (including signer, to, nonce, amount, callData) and the signature using Metamask.

- Afterward, you can deploy the [SignatureDemo.sol](./contracts/SignatureDemo.sol) to [Remix](https://remix.ethereum.org/) and call the execute() function to recover the signer from the signature, using the provided data packet and signature.
