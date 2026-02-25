const { MenuItem } = require('../models');

// GET /api/menu/:restaurantId
exports.getByRestaurant = async (req, res, next) => {
    try {
        const items = await MenuItem.findAll({
            where: { restaurant_id: req.params.restaurantId },
            order: [['is_popular', 'DESC'], ['name', 'ASC']],
        });
        res.json({ success: true, data: items });
    } catch (err) {
        next(err);
    }
};

// GET /api/menu/item/:id
exports.getById = async (req, res, next) => {
    try {
        const item = await MenuItem.findByPk(req.params.id, {
            include: [{ association: 'restaurant', attributes: ['id', 'name'] }],
        });
        if (!item) {
            return res.status(404).json({ success: false, error: 'Menu item not found' });
        }
        res.json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
};
