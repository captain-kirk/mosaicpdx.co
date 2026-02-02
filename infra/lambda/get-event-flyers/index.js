const { S3Client, ListObjectsV2Command } = require("@aws-sdk/client-s3");

const s3 = new S3Client({});
const BUCKET_NAME = process.env.BUCKET_NAME;
const CLOUDFRONT_DOMAIN = process.env.CLOUDFRONT_DOMAIN;
const ALLOWED_ORIGINS = [
  'https://mosaicpdx.co',
];

async function listFlyers(prefix) {
  const command = new ListObjectsV2Command({
    Bucket: BUCKET_NAME,
    Prefix: prefix,
  });
  const response = await s3.send(command);

  return (response.Contents || [])
    .filter(obj => obj.Key.endsWith('.png') && obj.Key !== prefix)
    .sort((a, b) => b.LastModified - a.LastModified)
    .map(obj => ({
      url: `https://${CLOUDFRONT_DOMAIN}/${obj.Key}`,
      key: obj.Key,
      lastModified: obj.LastModified.toISOString(),
    }));
}

exports.handler = async (event) => {
  const origin = event.headers.origin || event.headers.Origin;
  const headers = {};
  if (ALLOWED_ORIGINS.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
    headers['Access-Control-Allow-Credentials'] = true;
  }

  try {
    const [upcoming, past] = await Promise.all([
      listFlyers("events/upcoming/"),
      listFlyers("events/past/"),
    ]);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ upcoming, past }),
    };
  } catch (error) {
    console.error("Error listing event flyers:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ message: "Internal Server Error" }),
    };
  }
};
