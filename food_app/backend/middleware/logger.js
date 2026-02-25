/**
 * Custom request logger middleware
 * Logs method, URL, and timestamp for every incoming request
 */
const logger = (req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.originalUrl}`);

    // Track response time
    const start = Date.now();
    res.on('finish', () => {
        const duration = Date.now() - start;
        console.log(`[${timestamp}] ${req.method} ${req.originalUrl} → ${res.statusCode} (${duration}ms)`);
    });

    next();
};

module.exports = logger;
