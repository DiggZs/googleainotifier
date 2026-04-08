import { VertexAI } from '@google-cloud/vertexai';

const vertex = new VertexAI({
  project: process.env.GOOGLE_CLOUD_PROJECT,
  location: process.env.GOOGLE_CLOUD_REGION,
});

const model = vertex.getGenerativeModel({ model: 'gemini-2.0-flash-001' });

export async function generateMessage() {
  const result = await model.generateContent(
    // TODO: Replace with your actual prompt
    'Generate a brief daily summary message for the team.',
  );

  return result.response.candidates[0].content.parts[0].text;
}
