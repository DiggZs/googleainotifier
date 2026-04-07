import { GoogleAuth } from 'google-auth-library';

const SPACE_NAME = process.env.CHAT_SPACE_NAME;

const auth = new GoogleAuth({
  scopes: ['https://www.googleapis.com/auth/chat.bot'],
});

export async function postToChat(text) {
  if (!SPACE_NAME) throw new Error('CHAT_SPACE_NAME env var is not set');

  const client = await auth.getClient();
  const { token } = await client.getAccessToken();

  const url = `https://chat.googleapis.com/v1/${SPACE_NAME}/messages`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ text }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Chat API error ${res.status}: ${body}`);
  }

  return res.json();
}
