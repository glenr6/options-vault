import React, { useState } from "react";

const ConnectWallet = () => {
	const [isConnected, setIsConnected] = useState(false);
	const [error, setError] = useState(null);

	const connectToMetaMask = async () => {
		if (window.ethereum) {
			try {
				await window.ethereum.enable();
				setIsConnected(true);
			} catch (error) {
				console.error("User rejected access to MetaMask");
			}
		} else {
			setError("MetaMask is not installed. Please download MetaMask to continue.");
		}
	};

	return (
		<div>
			{error && <p>{error}</p>}
			{isConnected ? (
				<p>Your MetaMask wallet is connected!</p>
			) : (
				<button onClick={connectToMetaMask}>Connect Wallet</button>
			)}
		</div>
	);
};

export default ConnectWallet;
