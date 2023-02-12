import "./App.css";

import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";

import SideBar from "./components/SideBar.js";
import Options from "./pages/Options.js";
import ComingSoon from "./pages/ComingSoon.js";

function App() {
	return (
		<div className="App">
			<BrowserRouter>
				<SideBar />
				<Routes>
					<Route exact path="/" element={ <Options /> } />
					<Route path="/dashboard" element={ <ComingSoon /> } />
					<Route path="/options" element={ <Options /> } />
					<Route path="/swaps" element={ <ComingSoon /> } />
					<Route path="/explorer" element={ <ComingSoon /> } />
					<Route path="/docs" element={ <ComingSoon /> } />
				</Routes>
			</BrowserRouter>
		</div>
	);
}

export default App;