// @dev this is a file to manage the logic of converting time from dd/mm/yyyy input to a unix timestamp (and back)
    // will be used when user inputs their expiration date and also when 
    // solidity contracts use unix time

// JUST AN EXAMPLE if logic that will be implemented. NOT READY FOR PROUDCTION

import React, { useState } from 'react';

    const ConvertToUnix = () => {
      const [inputDate, setInputDate] = useState('');
      const [unixTime, setUnixTime] = useState('');
    
      const handleDateChange = (event) => {
        setInputDate(event.target.value);
      };
    
      const handleSubmit = (event) => {
        event.preventDefault();
        const dateArray = inputDate.split('/');
        const date = new Date(dateArray[2], dateArray[1] - 1, dateArray[0]);
        setUnixTime(date.getTime() / 1000);
      };
    
      return (
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Enter date in dd/mm/yyyy format"
            value={inputDate}
            onChange={handleDateChange}
          />
          <button type="submit">Convert to Unix Time</button>
          {unixTime ? <p>Unix time: {unixTime}</p> : null}
        </form>
      );
    };
    
    export default ConvertToUnix;
    