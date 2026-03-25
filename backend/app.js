import express from "express";
import AWS from "aws-sdk";

const app = express();
app.use(express.json());

AWS.config.update({ region: "ap-south-1" });

const dynamo = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3();

// 🔹 Save todo → DynamoDB
app.post("/todo", async (req, res) => {
  const { id, task } = req.body;

  await dynamo.put({
    TableName: "todo-table",
    Item: { id, task, status: "pending" }
  }).promise();

  res.send("Saved in DynamoDB");
});

// 🔹 Get todos
app.get("/todo", async (req, res) => {
  const data = await dynamo.scan({
    TableName: "todo-table"
  }).promise();

  res.json(data.Items);
});

// 🔹 Upload file → S3
app.get("/upload", async (req, res) => {
  await s3.putObject({
    Bucket: "jenish-todo-app-bucket",
    Key: "demo.txt",
    Body: "Hello from EKS"
  }).promise();

  res.send("Uploaded to S3");
});

app.listen(3000, () => console.log("Backend running on port 3000"));