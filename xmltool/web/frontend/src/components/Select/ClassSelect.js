import React, { useEffect, useState } from "react";
import Select from "react-select";
import selectStyles from "./selectStyles";

const ClassSelect = ({ onChange }) => {
  const [classes, setClasses] = useState([]);

  useEffect(() => {
    const fetchClasses = async () => {
      const res = await fetch('/classes');
      const data = await res.json();
      setClasses(data);
    };

    fetchClasses();
  }, []);

  return (
    <Select
      id="class-select"
      options={classes}
      styles={selectStyles}
      onChange={onChange}
      placeholder="Select a class"
    />
  );
}

export default ClassSelect;