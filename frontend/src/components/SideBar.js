import React, { useState } from "react";
import { Link } from "react-router-dom";
import { FaDiscord, FaGithub, FaTelegramPlane } from "react-icons/fa";

// import "../styles/sidebar.css";
import "../styles/cope.css";
// import ConnectWallet from "./components/ConnectWallet";

// import useExternalScripts from "../hooks/useExternalScripts";

const Sidebar = () => {
	const [darkMode, setDarkMode] = useState(false);

	// useExternalScripts("https://unpkg.com/boxicons@2.1.1/css/boxicons.min.css")

	return (
		<nav className="sidebar">
			<header>
				<div className="image-text">
					<span className="image">
						<img src="logo.png" alt="" />
					</span>

					<div className="text logo-text">
						<span className="name">glenrose.eth</span>
						<span className="profession">0x2er3fsef34...</span>
					</div>
				</div>

				<i className='bx bx-chevron-right toggle'></i>
			</header>

			<div className="menu-bar">
				<div className="menu">
					<ul className="menu-links">
						<li className="nav-link">
							<Link to="/dashboard" className="sidebar-option">
								<i className="bx bx-home-alt icon"></i>
								<span className="text nav-text">Dashboard</span>
							</Link>
						</li>
						<li className="nav-link">
							<Link to="/options" className="sidebar-option">
								<i className="bx bx-home-alt icon"></i>
								<span className="text nav-text">Options</span>
							</Link>
						</li>
						<li className="nav-link">
							<Link to="/swaps" className="sidebar-option">
								<i className="bx bx-home-alt icon"></i>
								<span className="text nav-text">Swaps</span>
							</Link>
						</li>
						<li className="nav-link">
							<Link to="/explorer" className="sidebar-option">
								<i className="bx bx-home-alt icon"></i>
								<span className="text nav-text">Explorer</span>
							</Link>
						</li>
						<li className="nav-link">
							<Link to="/docs" className="sidebar-option">
								<i className="bx bx-home-alt icon"></i>
								<span className="text nav-text">Docs</span>
							</Link>
						</li>
					</ul>
				</div>
			</div>

			<div className="bottom-content">
				<li className="mode" onClick={() => setDarkMode(!darkMode)}>
					<div className="sun-moon">
						<i className="bx bx-moon icon moon"></i>
						<i className="bx bx-sun icon sun"></i>
					</div>
					<span className="mode-text text">Dark Mode</span>

					<div className="toggle-switch">
						<span className="switch"></span>
					</div>
				</li>

				<li className="socials">
					<a href="#" className="sidebar-telegram">
						<FaTelegramPlane />
						{/* <i class="bx bx-telegram icon"></i> */}
					</a>
					<a href="#" className="sidebar-discord">
						<FaDiscord />
						{/* <i class="bx bx-discord icon"></i> */}
					</a>
					<a href="#" className="sidebar-github">
						<FaGithub />
						{/* <i class="bx bx-github icon"></i> */}
					</a>
				</li>
			</div>
		</nav>
	);
};

export default Sidebar;


{/* <div className="sidebar-mode-toggle">
	<button onClick={() => setDarkMode(!darkMode)}>
		{darkMode ? "Light Mode" : "Dark Mode"}
	</button>
</div> */}