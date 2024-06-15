import React, { useEffect, useState } from "react";
import Select from "react-select";
import selectStyles from "./selectStyles";

const RaceSelect = ({ onChange }) => {
  const [races, setRaces] = useState([]);

  useEffect(() => {
    const fetchRaces = async () => {
      const res = await fetch('/races');
      const data = await res.json();
      setRaces(data);
    };

    fetchRaces();
  }, []);



  return (
    <Select
      id="race-select"
      options={races}
      styles={selectStyles}
      onChange={onChange}
      placeholder="Select a Race"
    />
  );
}

export default RaceSelect;