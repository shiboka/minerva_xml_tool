import React from "react";
import Form from "react-bootstrap/Form";
import "./SkillChain.css";

const SkillChain = () => {
  return (
    <div id="skill-chain-container">
      <Form.Group controlId="skill-chain">
        <Form.Check type="checkbox" label="Chain skills" />
      </Form.Group>
    </div>
  );
}

export default SkillChain;