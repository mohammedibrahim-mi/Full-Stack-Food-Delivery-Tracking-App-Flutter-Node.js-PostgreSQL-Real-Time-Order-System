const { Category } = require('../models');

// GET /api/categories
exports.getAll = async (req, res, next) => {
    try {
        const categories = await Category.findAll({ order: [['id', 'ASC']] });
        res.json({ success: true, data: categories });
    } catch (err) {
        next(err);
    }
};

// GET /api/categories/:id
exports.getById = async (req, res, next) => {
    try {
        const category = await Category.findByPk(req.params.id, {
            include: [{ association: 'restaurants' }],
        });
        if (!category) {
            return res.status(404).json({ success: false, error: 'Category not found' });
        }
        res.json({ success: true, data: category });
    } catch (err) {
        next(err);
    }
};
