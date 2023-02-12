const Web3 = require("web3") // for nodejs only
const web3 = new Web3("https://rpc.ankr.com/arbitrum")
const aggregatorV3InterfaceABI = [
	{
		inputs: [],
		name: "latestRoundData",
		outputs: [
			{ internalType: "uint80", name: "roundId", type: "uint80" },
			{ internalType: "int256", name: "answer", type: "int256" },
			{ internalType: "uint256", name: "startedAt", type: "uint256" },
			{ internalType: "uint256", name: "updatedAt", type: "uint256" },
			{ internalType: "uint80", name: "answeredInRound", type: "uint80" },
		],
		stateMutability: "view",
		type: "function",
	},
]
const addr = "0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612"
const priceFeed = new web3.eth.Contract(aggregatorV3InterfaceABI, addr)

async function getEthSpotPrice() {
	let result = await priceFeed.methods.latestRoundData().call().then((roundData) => {
		return roundData.answer / Math.pow(10, 8);
	})

	return result;
}

module.exports = { getEthSpotPrice };