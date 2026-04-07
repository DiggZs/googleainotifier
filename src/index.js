import express from 'express';
import { generateMessage } from './llm.js';
import { postToChat } from './chat.js';

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8080;

app.post('/run-scheduled-task', async (req, res) => {
  try {
    const text = await generateMessage();
    await postToChat(text);
    res.json({ status: 'ok' });
  } catch (err) {
    console.error('Scheduled task failed:', err);
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
