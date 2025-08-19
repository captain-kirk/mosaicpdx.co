const AWS = require('aws-sdk');

const dynamoDb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    // Scan the DynamoDB table to retrieve all emails
    const params = {
      TableName: TABLE_NAME,
      ProjectionExpression: "email, timestamp", // Only retrieve specific attributes
    };

    const result = await dynamoDb.scan(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        data: result.Items,
      }),
    };
  } catch (error) {
    console.error('Error retrieving emails:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal Server Error' }),
    };
  }
};