const { createApp } = require('./app');

const PORT = Number(process.env.PORT || 8788);
const app = createApp();

app.listen(PORT, () => {
  console.log(`RateGold ops listening on http://127.0.0.1:${PORT}`);
  console.log(`Admin UI: http://127.0.0.1:${PORT}/`);
});
