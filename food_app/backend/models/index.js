const sequelize = require('../config/db');
const User = require('./User');
const Category = require('./Category');
const Restaurant = require('./Restaurant');
const MenuItem = require('./MenuItem');
const Order = require('./Order');
const OrderItem = require('./OrderItem');
const Cart = require('./Cart');

// ─── Associations ────────────────────────────────────────────────
Category.hasMany(Restaurant, { foreignKey: 'category_id', as: 'restaurants' });
Restaurant.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

Restaurant.hasMany(MenuItem, { foreignKey: 'restaurant_id', as: 'menuItems' });
MenuItem.belongsTo(Restaurant, { foreignKey: 'restaurant_id', as: 'restaurant' });

User.hasMany(Order, { foreignKey: 'user_id', as: 'orders' });
Order.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

Restaurant.hasMany(Order, { foreignKey: 'restaurant_id', as: 'orders' });
Order.belongsTo(Restaurant, { foreignKey: 'restaurant_id', as: 'restaurant' });

Order.hasMany(OrderItem, { foreignKey: 'order_id', as: 'items' });
OrderItem.belongsTo(Order, { foreignKey: 'order_id', as: 'order' });

OrderItem.belongsTo(MenuItem, { foreignKey: 'menu_item_id', as: 'menuItem' });

User.hasMany(Cart, { foreignKey: 'user_id', as: 'cartItems' });
Cart.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

Cart.belongsTo(MenuItem, { foreignKey: 'menu_item_id', as: 'menuItem' });
MenuItem.hasMany(Cart, { foreignKey: 'menu_item_id', as: 'cartEntries' });

module.exports = {
    sequelize,
    User,
    Category,
    Restaurant,
    MenuItem,
    Order,
    OrderItem,
    Cart,
};
