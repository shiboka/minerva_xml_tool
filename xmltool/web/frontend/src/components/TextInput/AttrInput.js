import React from "react";
import Form from "react-bootstrap/Form";
import "./TextInput.css";

const AttrInput = () => {
  return (
    <Form.Group controlId="attr-input">
      <Form.Control type="text" placeholder="Enter the XML attributes here" />
    </Form.Group>
  );
}

export default AttrInput;