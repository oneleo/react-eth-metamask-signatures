import { useState, useRef } from "react";
import { ethers } from "ethers";
import ErrorMessage from "./ErrorMessage";
import { abi as abiErc20 } from "@openzeppelin/contracts/build/contracts/ERC20.json";

const signMessage = async ({ setError, token, nonce, to, amount }) => {
  try {
    if (!window.ethereum) {
      throw new Error("No crypto wallet found. Please install it.");
    }
    await window.ethereum.request({ method: "eth_requestAccounts" });

    let UsdtAddress = ethers.constants.AddressZero;
    let UsdtDecimal = 6;

    switch (window.ethereum.networkVersion) {
      case "1": // Mainnet
        UsdtAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
        UsdtDecimal = 6;
        break;
      case "5": // Goerli
        UsdtAddress = "0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49";
        UsdtDecimal = 6;
        break;
      case "11155111": // Sepolia
        UsdtAddress = "0x6175a8471C2122f778445e7E07A164250a19E661";
        // UsdtAddress = "0xB6434EE024892CBD8e3364048a259Ef779542475";
        UsdtDecimal = 18;
        break;
      default:
        break;
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const signerAddress = await signer.getAddress();
    const usdtInterface = new ethers.utils.Interface(abiErc20);

    let toAddress = to;
    let value = ethers.BigNumber.from("0");
    let callData = ethers.utils.hexlify("0x");

    switch (token) {
      case "ETH":
        value = ethers.utils.parseUnits(amount, 18);
        break;
      case "USDT":
        toAddress = UsdtAddress;
        callData = usdtInterface.encodeFunctionData("transfer", [
          ethers.utils.getAddress(to),
          ethers.utils.parseUnits(amount, UsdtDecimal),
        ]);
        break;
      default:
        break;
    }

    // const dataPack = ethers.utils.solidityPack( // Error
    //   ["address", "uint256", "bytes"],
    //   [target, value, callData]
    // );
    // Solidity: _data = abi.encode(address signer, address to, uint256 nonce, uint256 amount, bytes memory callData);
    const dataPack = ethers.utils.defaultAbiCoder.encode(
      ["address", "address", "uint256", "uint256", "bytes"],
      // from, to, nonce, amount, callData
      [signerAddress, toAddress, nonce, value, callData]
    );

    // const dataHash = ethers.utils.solidityKeccak256(["bytes"], [dataPack]); // Error
    const dataHash = ethers.utils.keccak256(dataPack);
    const dataHashToUint8Array = ethers.utils.arrayify(dataHash);
    const signature = await signer.signMessage(dataHashToUint8Array);
    console.log(
      `ChainId: ${window.ethereum.networkVersion}\n ↳ USDT Address: ${UsdtAddress}\nToken: ${token}\nSigner: ${signerAddress}\nTo: ${toAddress}\nNonce: ${nonce}\nValue: ${value}\nCallData: ${callData}\nDataHash: ${dataHash}`
    );

    return {
      dataPack,
      signature,
    };
  } catch (err) {
    setError(err.message);
  }
};

export default function SignMessage() {
  const resultBox = useRef();
  const [signatures, setSignatures] = useState([]);
  const [error, setError] = useState();

  const handleSign = async (e) => {
    e.preventDefault();
    const data = new FormData(e.target);
    setError();
    const sig = await signMessage({
      setError,
      token: data.get("token"),
      nonce: data.get("nonce"),
      to: data.get("to"),
      amount: data.get("amount"),
    });
    if (sig) {
      setSignatures([...signatures, sig]);
    }
  };

  return (
    <form className="m-4" onSubmit={handleSign}>
      <div className="credit-card w-full shadow-lg mx-auto rounded-xl bg-white">
        <main className="mt-4 p-4">
          <h1 className="text-xl font-semibold text-gray-700 text-center">
            Sign messages
          </h1>
          <div className="">
            <div className="my-3">
              <select
                required
                name="token"
                className="select w-full input input-bordered focus:ring focus:outline-none"
              >
                <option value="ETH">ETH</option>
                <option value="USDT">USDT</option>
              </select>
            </div>
            <div className="my-3">
              <input
                required
                type="text"
                name="nonce"
                className="textarea w-full input input-bordered focus:ring focus:outline-none"
                placeholder="Nonce"
              />
            </div>
            <div className="my-3">
              <input
                required
                type="text"
                name="to"
                className="textarea w-full input input-bordered focus:ring focus:outline-none"
                placeholder="To address"
              />
            </div>
            <div className="my-3">
              <input
                required
                type="text"
                name="amount"
                className="textarea w-full input input-bordered focus:ring focus:outline-none"
                placeholder="Token amount"
              />
            </div>
          </div>
        </main>
        <footer className="p-4">
          <button
            type="submit"
            className="btn btn-primary submit-button focus:ring focus:outline-none w-full"
          >
            Sign message
          </button>
          <ErrorMessage message={error} />
        </footer>
        {signatures.map((sig, idx) => {
          return (
            <div className="p-2" key={idx}>
              <div className="my-3">
                <textarea
                  type="text"
                  readOnly
                  ref={resultBox}
                  className="textarea w-full h-24 textarea-bordered focus:ring focus:outline-none"
                  placeholder="Message"
                  value={`Message ${idx + 1}: ${sig.dataPack}`}
                />
                <textarea
                  type="text"
                  readOnly
                  ref={resultBox}
                  className="textarea w-full h-24 textarea-bordered focus:ring focus:outline-none"
                  placeholder="Generated signature"
                  value={`Signature ${idx + 1}: ${sig.signature}`}
                />
              </div>
            </div>
          );
        })}
      </div>
    </form>
  );
}
