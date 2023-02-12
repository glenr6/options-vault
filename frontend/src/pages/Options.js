import React, { useEffect, useState } from "react";

import dayjs from "dayjs";
import TextField from "@mui/material/TextField";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DesktopDatePicker } from "@mui/x-date-pickers/DesktopDatePicker";
import MenuItem from '@mui/material/MenuItem';

import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import FormLabel from '@mui/material/FormLabel';

// import { makeStyles } from '@material-ui/core/styles';

import Button from '@mui/material/Button';
import ButtonGroup from '@mui/material/ButtonGroup';
import Box from '@mui/material/Box';

import "../styles/options.css";

const BlackScholes = require("../components/scripts/BlackScholes");
const ChainlinkFeed = require("../components/scripts/ChainLinkFeed");


// import ConnectWallet from "../components/ConnectWallet";

const cryptoassets = [
	{
		value: "ETH",
		label: "Ethereum",
	}
]

// const useStyles = makeStyles({
// 	input: {
// 	  width: 500,
// 	},
//   });

const Options = () => {
	// const classes = useStyles();
	const [optionType, setOptionType] = useState(true);
	const [orderType, setOrderType] = useState(true);

	const [amount, setAmount] = useState(0);
	const [marketPrice, getMarketPrice] = useState(null);

	useEffect(() => {
		ChainlinkFeed.getEthSpotPrice().then(price => getMarketPrice(price)).catch(error => console.error(error));
	}, []);

	const [strikePrice, setStrikePrice] = useState(0);

	useEffect(() => {
		if (marketPrice !== null) {
			setStrikePrice(Math.round(marketPrice / 100) * 100);
		}
	}, [marketPrice]);

	const [assetSymbol, setassetSymbol] = useState("ETH");
	const [expirationDate, setExpirationDate] = useState(dayjs());

	const [optionPrice, setPrice] = useState(0);

	useEffect(() => {
		const getPrice = async () => {
			const result = await BlackScholes.blackScholes(strikePrice, expirationDate.unix(), true);
			setPrice(result.toFixed(2));
		};
		getPrice();
	}, [strikePrice, expirationDate]);

	const handleSubmit = (e) => {
		e.preventDefault();

		let estimatedPrice = BlackScholes.blackScholes(strikePrice, expirationDate.unix(), true);
		console.log(estimatedPrice);
		console.log("Price is" + optionPrice);
		console.log(`Option Type: ${optionType} | Order Type: ${orderType}`)

		// Create an instance of the Web3.js library
		const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

		// Define the contract ABI and address
		const contractABI = [...]
		const contractAddress = "0x..."
			
		// Create a contract instance
		const contractInstance = new web3.eth.Contract(contractABI, contractAddress);
			
		// Call the depositCollateral function of the contract
		try {
			const result = await contractInstance.methods.depositCollateral(strikePrice, assetName, underlyingQty).send({ from: web3.eth.defaultAccount });
			console.log("Transaction successful: ", result);
		} catch (error) {
			console.error("Transaction failed: ", error);
		}
	};

	return (
		<div className="optionsForm">
			<form onSubmit={handleSubmit}>
				<ButtonGroup size="medium" aria-label="button group">
					<Button onClick={() => setOptionType(true)}>Call</Button>
					<Button onClick={() => setOptionType(false)}>Put</Button>
				</ButtonGroup>
				<br />
				<br />
				<ButtonGroup color="secondary" aria-label="medium secondary button group">
					<Button onClick={() => setOptionType(true)}>Buy</Button>
					<Button onClick={() => setOptionType(false)}>Sell</Button>
				</ButtonGroup>
				<br />
				<br />
				<TextField id="outlined-select-currency"
					select
					label="Asset"
					defaultValue="ETH"
					value={assetSymbol}
					onChange={(e) => setassetSymbol(e.target.value)}
				    // className={classes.input}
				>
					{cryptoassets.map((option) => (
						<MenuItem key={option.value} value={option.value}>
							{option.label}
						</MenuItem>
					))}
				</TextField>
				<br />
				<br />
				<TextField
					id="outlined-basic"
					label="Strike Price"
					value={strikePrice}
					onChange={(e) => setStrikePrice(e.target.value)}
					variant="outlined"
					// className={classes.input}
				/>
				<br />
				<br />
				<TextField
					id="outlined-basic"
					label="Amount"
					value={amount}
					onChange={(e) => setAmount(e.target.value)}
					variant="outlined"
					// className={classes.input}
				/>
				<br />
				<br />
				<LocalizationProvider dateAdapter={AdapterDayjs}>
					<DesktopDatePicker
						label="Expiration Date"
						value={expirationDate}
						minDate={dayjs()}
						// className={classes.input}
						onChange={(newValue) => { setExpirationDate(newValue); }}
						renderInput={(params) => <TextField {...params} />}
					/>
				</LocalizationProvider>
				<br />
				<p>Estimated Option Price: ${optionPrice}</p>
				<br />
				<Button variant="outlined" type="submit">Mint NFT</Button>
			</form>
		</div>
	);
};

export default Options;