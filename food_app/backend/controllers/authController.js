const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'foodie_super_secret_jwt_key_2026';

// POST /api/auth/register
exports.register = async (req, res, next) => {
    try {
        const { name, email, password, phone, address } = req.body;

        const exists = await User.findOne({ where: { email } });
        if (exists) {
            return res.status(409).json({ success: false, error: 'Email already registered' });
        }

        const password_hash = await bcrypt.hash(password, 10);
        const user = await User.create({ name, email, password_hash, phone: phone || '', address: address || '' });

        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '30d' });

        res.status(201).json({
            success: true,
            data: {
                token,
                user: { id: user.id, name: user.name, email: user.email, phone: user.phone, address: user.address, avatar_url: user.avatar_url },
            },
        });
    } catch (err) {
        next(err);
    }
};

// POST /api/auth/login
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        const match = await bcrypt.compare(password, user.password_hash);
        if (!match) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '30d' });

        res.json({
            success: true,
            data: {
                token,
                user: { id: user.id, name: user.name, email: user.email, phone: user.phone, address: user.address, avatar_url: user.avatar_url },
            },
        });
    } catch (err) {
        next(err);
    }
};

// GET /api/auth/me
exports.getMe = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.userId, {
            attributes: ['id', 'name', 'email', 'phone', 'address', 'avatar_url'],
        });
        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }
        res.json({ success: true, data: user });
    } catch (err) {
        next(err);
    }
};
