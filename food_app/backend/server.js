require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

// Database
const { sequelize } = require('./models');

// Custom middleware
const logger = require('./middleware/logger');
const errorHandler = require('./middleware/errorHandler');

// Route modules
const authRoutes = require('./routes/auth');
const categoriesRoutes = require('./routes/categories');
const restaurantsRoutes = require('./routes/restaurants');
const menuRoutes = require('./routes/menu');
const cartRoutes = require('./routes/cart');
const ordersRoutes = require('./routes/orders');

// ─── Create Express App ──────────────────────────────────────────────
const app = express();
const PORT = process.env.PORT || 4000;

// ─── Global Middleware ───────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use(logger);

// ─── Health Check ────────────────────────────────────────────────────
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: '🍔 Foodie API is running!',
        version: '2.0.0',
        database: 'PostgreSQL',
        endpoints: {
            auth: '/api/auth (register, login, me)',
            categories: '/api/categories',
            restaurants: '/api/restaurants',
            menu: '/api/menu/:restaurantId',
            cart: '/api/cart  (auth required)',
            orders: '/api/orders  (auth required)',
        },
    });
});

// ─── API Routes ──────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/restaurants', restaurantsRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', ordersRoutes);

// ─── 404 Handler ─────────────────────────────────────────────────────
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: `Route ${req.originalUrl} not found`,
    });
});

// ─── Global Error Handler ────────────────────────────────────────────
app.use(errorHandler);

// ─── Start Server (sync DB first) ────────────────────────────────────
async function start() {
    try {
        await sequelize.authenticate();
        console.log('✅ PostgreSQL connected');

        await sequelize.sync({ alter: true });
        console.log('✅ Database synced');

        app.listen(PORT, () => {
            console.log(`\n🚀 Foodie API v2.0 running on http://localhost:${PORT}`);
            console.log(`📋 Health check: http://localhost:${PORT}\n`);
        });
    } catch (err) {
        console.error('❌ Failed to start server:', err.message);
        process.exit(1);
    }
}

start();

module.exports = app;
