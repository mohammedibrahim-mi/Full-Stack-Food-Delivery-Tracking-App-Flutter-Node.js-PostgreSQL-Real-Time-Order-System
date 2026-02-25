const { Restaurant, Category, MenuItem } = require('../models');
const { Op } = require('sequelize');

// GET /api/restaurants
exports.getAll = async (req, res, next) => {
    try {
        const where = {};
        if (req.query.featured === 'true') where.is_featured = true;
        if (req.query.category) where.category_id = req.query.category;
        if (req.query.search) {
            where.name = { [Op.iLike]: `%${req.query.search}%` };
        }

        const restaurants = await Restaurant.findAll({
            where,
            include: [{ association: 'category', attributes: ['id', 'name', 'icon'] }],
            order: [['rating', 'DESC']],
        });
        res.json({ success: true, data: restaurants });
    } catch (err) {
        next(err);
    }
};

// GET /api/restaurants/:id
exports.getById = async (req, res, next) => {
    try {
        const restaurant = await Restaurant.findByPk(req.params.id, {
            include: [
                { association: 'category', attributes: ['id', 'name', 'icon'] },
                { association: 'menuItems', order: [['is_popular', 'DESC']] },
            ],
        });
        if (!restaurant) {
            return res.status(404).json({ success: false, error: 'Restaurant not found' });
        }
        res.json({ success: true, data: restaurant });
    } catch (err) {
        next(err);
    }
};
