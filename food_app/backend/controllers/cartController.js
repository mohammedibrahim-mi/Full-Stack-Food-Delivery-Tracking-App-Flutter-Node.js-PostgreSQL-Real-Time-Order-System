const { Cart, MenuItem, Restaurant } = require('../models');

// GET /api/cart  (uses req.userId from auth middleware)
exports.getCart = async (req, res, next) => {
    try {
        const items = await Cart.findAll({
            where: { user_id: req.userId },
            include: [{
                association: 'menuItem',
                attributes: ['id', 'name', 'description', 'price', 'image_url', 'restaurant_id'],
                include: [{ association: 'restaurant', attributes: ['id', 'name'] }],
            }],
            order: [['created_at', 'ASC']],
        });

        const cartItems = items.map(ci => ({
            id: ci.id,
            quantity: ci.quantity,
            menuItem: ci.menuItem,
        }));

        const total = cartItems.reduce((sum, ci) => sum + ci.menuItem.price * ci.quantity, 0);

        res.json({ success: true, data: { items: cartItems, total: Math.round(total * 100) / 100 } });
    } catch (err) {
        next(err);
    }
};

// POST /api/cart  body: { menuItemId, quantity }
exports.addItem = async (req, res, next) => {
    try {
        const { menuItemId, quantity = 1 } = req.body;

        const menuItem = await MenuItem.findByPk(menuItemId);
        if (!menuItem) {
            return res.status(404).json({ success: false, error: 'Menu item not found' });
        }

        const existing = await Cart.findOne({
            where: { user_id: req.userId, menu_item_id: menuItemId },
        });

        if (existing) {
            existing.quantity += quantity;
            await existing.save();
            return res.json({ success: true, data: existing, message: 'Quantity updated' });
        }

        const cartItem = await Cart.create({
            user_id: req.userId,
            menu_item_id: menuItemId,
            quantity,
        });
        res.status(201).json({ success: true, data: cartItem });
    } catch (err) {
        next(err);
    }
};

// PUT /api/cart/:id  body: { quantity }
exports.updateItem = async (req, res, next) => {
    try {
        const cartItem = await Cart.findOne({
            where: { id: req.params.id, user_id: req.userId },
        });
        if (!cartItem) {
            return res.status(404).json({ success: false, error: 'Cart item not found' });
        }
        cartItem.quantity = req.body.quantity;
        await cartItem.save();
        res.json({ success: true, data: cartItem });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/cart/:id
exports.removeItem = async (req, res, next) => {
    try {
        const deleted = await Cart.destroy({
            where: { id: req.params.id, user_id: req.userId },
        });
        if (!deleted) {
            return res.status(404).json({ success: false, error: 'Cart item not found' });
        }
        res.json({ success: true, message: 'Item removed from cart' });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/cart  (clear entire cart)
exports.clearCart = async (req, res, next) => {
    try {
        await Cart.destroy({ where: { user_id: req.userId } });
        res.json({ success: true, message: 'Cart cleared' });
    } catch (err) {
        next(err);
    }
};
