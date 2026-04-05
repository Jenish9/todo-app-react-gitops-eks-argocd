import express from "express";
import AWS from "aws-sdk";
import cors from "cors";

const app = express();
app.use(express.json());
app.use(cors());

const LOCAL_MODE = true; // 🔥 CHANGE THIS

let todos = []; // local storage

AWS.config.update({ region: "ap-south-1" });
const dynamo = new AWS.DynamoDB.DocumentClient();

// ✅ CREATE TODO
app.post("/api/todo", async (req, res) => {
  const { id, task } = req.body;

  if (LOCAL_MODE) {
    todos.push({ id, task });
    return res.json({ message: "Saved locally" });
  }

  await dynamo.put({
    TableName: "todo-table",
    Item: { id, task, status: "pending" },
  }).promise();

  res.send("Saved in DynamoDB");
});

// ✅ GET TODOS
app.get("/api/todo", async (req, res) => {
  if (LOCAL_MODE) {
    return res.json(todos);
  }

  const data = await dynamo.scan({
    TableName: "todo-table",
  }).promise();

  res.json(data.Items);
});

// ✅ DELETE TODO
app.delete("/api/todo/:id", async (req, res) => {
  const { id } = req.params;

  if (LOCAL_MODE) {
    todos = todos.filter((t) => t.id !== id);
    return res.send("Deleted locally");
  }

  await dynamo.delete({
    TableName: "todo-table",
    Key: { id },
  }).promise();

  res.send("Deleted from DynamoDB");
});

app.listen(5000, () => console.log("Backend running on port 5000"));