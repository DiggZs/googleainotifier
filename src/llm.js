import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export async function generateMessage() {
  const response = await anthropic.messages.create({
    model: 'claude-opus-4-6',
    max_tokens: 500,
    messages: [
      {
        role: 'user',
        // TODO: Replace with your actual prompt
        content: 'Generate a brief daily summary message for the team.',
      },
    ],
  });

  return response.content[0].text;
}
