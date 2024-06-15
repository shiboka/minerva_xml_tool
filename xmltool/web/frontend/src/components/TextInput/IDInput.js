import React from "react";
import Form from "react-bootstrap/Form";
import "./TextInput.css";

const IDInput = () => {
  return (
    <Form.Group controlId="id-input">
      <Form.Control type="text" placeholder="Enter the ID here" />
    </Form.Group>
  );
}

export default IDInput;