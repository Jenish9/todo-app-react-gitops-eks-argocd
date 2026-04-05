/*import React, { Component } from "react";
import "bootstrap/dist/css/bootstrap.css";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import InputGroup from "react-bootstrap/InputGroup";
import FormControl from "react-bootstrap/FormControl";
import ListGroup from "react-bootstrap/ListGroup";

const API_URL = ""
const API_URL = process.env.REACT_APP_API_URL 

|| "http://backend-service:3000";
const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000";
 const API_URL = "http://localhost:5000"; // change later for k8s 
const API_URL = "http://host.docker.internal:5000";
*/
import React, { Component } from "react";
import "bootstrap/dist/css/bootstrap.css";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import InputGroup from "react-bootstrap/InputGroup";
import FormControl from "react-bootstrap/FormControl";
import ListGroup from "react-bootstrap/ListGroup";

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      userInput: "",
      list: [],
    };
  }

  componentDidMount() {
    this.fetchTodos();
  }

  // ✅ FIX: make async
  async fetchTodos() {
    const res = await fetch("/api/todo");
    const data = await res.json();
    this.setState({ list: data });
  }

  // ✅ FIX: add back this function
  updateInput(value) {
    this.setState({
      userInput: value,
    });
  }

  // ✅ FIX: ONLY ONE addItem (async)
  async addItem() {
    if (this.state.userInput.trim() !== "") {
      await fetch("/api/todo", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          id: Date.now().toString(),
          task: this.state.userInput,
        }),
      });

      await this.fetchTodos();  // 🔥 wait properly
      this.setState({ userInput: "" });
    }
  }

  // ✅ FIX: async delete
  async deleteItem(id) {
    await fetch(`/api/todo/${id}`, {
      method: "DELETE",
    });

    await this.fetchTodos();  // 🔥 refresh properly
  }

  render() {
    return (
      <Container>
        <Row style={{ textAlign: "center", fontSize: "2rem", fontWeight: "bold" }}>
          TODO APP (DevOps Project 🚀)
        </Row>

        <hr />

        <Row>
          <Col md={{ span: 5, offset: 4 }}>
            <InputGroup className="mb-3">
              <FormControl
                placeholder="Add todo..."
                value={this.state.userInput}
                onChange={(e) => this.updateInput(e.target.value)}
              />
              <Button variant="dark" onClick={() => this.addItem()}>
                ADD
              </Button>
            </InputGroup>
          </Col>
        </Row>

        <Row>
          <Col md={{ span: 5, offset: 4 }}>
            <ListGroup>
              {this.state.list.map((item) => (
                <ListGroup.Item
                  key={item.id}
                  style={{ display: "flex", justifyContent: "space-between" }}
                >
                  {item.task}
                  <Button
                    variant="danger"
                    onClick={() => this.deleteItem(item.id)}
                  >
                    Delete
                  </Button>
                </ListGroup.Item>
              ))}
            </ListGroup>
          </Col>
        </Row>
      </Container>
    );
  }
}

export default App;