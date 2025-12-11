import express from 'express';
import multer from 'multer';

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

app.post('/api/verify/image', upload.single('image'), (req, res) => {
  // Canned PASS/FAIL demo: approve if filename contains 'pass'
  const filename = req.file?.originalname?.toLowerCase() || '';
  const result = filename.includes('pass') ? 'PASS' : 'FAIL';
  res.json({ result, confidence: result === 'PASS' ? 0.9 : 0.2, labels: [] });
});

app.listen(3000, () => console.log('Stub server proxy on :3000'));
