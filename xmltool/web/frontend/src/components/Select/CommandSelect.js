import React from "react";
import Select from "react-select";
import selectStyles from "./selectStyles";

const options = [
  { value: "skill", label: "Skill" },
  { value: "area", label: "Area" },
  { value: "stats", label: "Stats" },
  { value: "direct", label: "Direct" },
];

const CommandSelect = ({ onChange }) => {
  return (
    <Select
      id="command-select"
      options={options}
      styles={selectStyles}
      onChange={onChange}
      placeholder="Select a command"
    />
  );
}

export default CommandSelect;