/**
 * Global error handler middleware
 * Catches errors thrown in routes/controllers and returns a consistent JSON response.
 */
const errorHandler = (err, req, res, _next) => {
    console.error('❌ Error:', err.message);
    console.error(err.stack);

    const statusCode = err.statusCode || 500;

    res.status(statusCode).json({
        success: false,
        error: err.message || 'Internal Server Error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};

module.exports = errorHandler;
