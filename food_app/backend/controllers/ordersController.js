const { Order, OrderItem, Cart, MenuItem, Restaurant } = require('../models');
const sequelize = require('../config/db');

// GET /api/orders
exports.getOrders = async (req, res, next) => {
    try {
        const orders = await Order.findAll({
            where: { user_id: req.userId },
            include: [{ association: 'items' }],
            order: [['created_at', 'DESC']],
        });
        res.json({ success: true, data: orders });
    } catch (err) {
        next(err);
    }
};

// GET /api/orders/:id
exports.getOrderById = async (req, res, next) => {
    try {
        const order = await Order.findOne({
            where: { id: req.params.id, user_id: req.userId },
            include: [{ association: 'items' }],
        });
        if (!order) {
            return res.status(404).json({ success: false, error: 'Order not found' });
        }
        res.json({ success: true, data: order });
    } catch (err) {
        next(err);
    }
};

// POST /api/orders  body: { deliveryAddress }
exports.placeOrder = async (req, res, next) => {
    const t = await sequelize.transaction();
    try {
        const cartItems = await Cart.findAll({
            where: { user_id: req.userId },
            include: [{
                association: 'menuItem',
                include: [{ association: 'restaurant', attributes: ['id', 'name'] }],
            }],
            transaction: t,
        });

        if (cartItems.length === 0) {
            await t.rollback();
            return res.status(400).json({ success: false, error: 'Cart is empty' });
        }

        // Pick restaurant from first item
        const restaurant = cartItems[0].menuItem.restaurant;
        const total = cartItems.reduce((sum, ci) => sum + ci.menuItem.price * ci.quantity, 0);

        const order = await Order.create({
            user_id: req.userId,
            restaurant_id: restaurant ? restaurant.id : null,
            restaurant_name: restaurant ? restaurant.name : '',
            total: Math.round(total * 100) / 100,
            status: 'confirmed',
            delivery_address: req.body.deliveryAddress || '',
        }, { transaction: t });

        const orderItemsData = cartItems.map(ci => ({
            order_id: order.id,
            menu_item_id: ci.menu_item_id,
            name: ci.menuItem.name,
            quantity: ci.quantity,
            price: ci.menuItem.price,
        }));

        await OrderItem.bulkCreate(orderItemsData, { transaction: t });
        await Cart.destroy({ where: { user_id: req.userId }, transaction: t });

        await t.commit();

        // Re-fetch with items
        const fullOrder = await Order.findByPk(order.id, {
            include: [{ association: 'items' }],
        });

        res.status(201).json({ success: true, data: fullOrder });
    } catch (err) {
        await t.rollback();
        next(err);
    }
};
