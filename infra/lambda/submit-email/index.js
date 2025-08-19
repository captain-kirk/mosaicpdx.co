const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamoDb = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME;
const ALLOWED_ORIGINS = [
  'https://mosaicpdx.co',
];

exports.handler = async (event) => {
  const origin = event.headers.origin || event.headers.Origin;
  const headers = {};
  if (ALLOWED_ORIGINS.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
    headers['Access-Control-Allow-Credentials'] = true;
  }

  const { email } = JSON.parse(event.body);

  if (!email) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ message: "Email is required" }),
    };
  }

  // 1. Use GetItem to check if the email already exists
  const getParams = {
    TableName: TABLE_NAME,
    Key: {
      email: email,
    },
  };

  try {
    const { Item } = await dynamoDb.send(new GetCommand(getParams));

    if (Item) {
      return {
        statusCode: 200, // Or 409 Conflict
        headers,
        body: JSON.stringify({ message: "Email already exists" }),
      };
    }

    // 2. If it doesn't exist, add it to the table
    const putParams = {
      TableName: TABLE_NAME,
      Item: {
        email: email,
        timestamp: new Date().toISOString(),
      },
    };

    await dynamoDb.send(new PutCommand(putParams));

    return {
      statusCode: 201, // 201 Created is more appropriate
      headers,
      body: JSON.stringify({ message: "Email submitted successfully" }),
    };
  } catch (error) {
    console.error("Error processing email:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ message: "Internal Server Error" }),
    };
  }
};