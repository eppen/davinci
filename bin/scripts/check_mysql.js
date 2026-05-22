const mysql = require('mysql2/promise');
(async () => {
  try {
    const c = await mysql.createConnection({
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: 'root',
    });
    const [d] = await c.query("SHOW DATABASES LIKE 'davinci0.3'");
    console.log('db:', d.length ? 'exists' : 'missing');
    if (d.length) {
      const [t] = await c.query('SHOW TABLES FROM `davinci0.3`');
      console.log('tables:', t.length);
    }
    await c.end();
  } catch (e) {
    console.error('ERR:', e.code || e.errno, e.message);
    process.exit(1);
  }
})();
