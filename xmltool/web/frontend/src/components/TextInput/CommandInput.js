import React from "react";
import Form from "react-bootstrap/Form";
import "./TextInput.css";

const CommandInput = () => {
  return (
    <Form.Group controlId="command-input">
      <Form.Control type="text" placeholder="Enter the command here" />
    </Form.Group>
  );
}

export default CommandInput;