const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Order = sequelize.define('Order', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    restaurant_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    total: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 0,
    },
    status: {
        type: DataTypes.ENUM('pending', 'confirmed', 'preparing', 'on_the_way', 'delivered', 'cancelled'),
        defaultValue: 'pending',
    },
    delivery_address: {
        type: DataTypes.TEXT,
        defaultValue: '',
    },
    restaurant_name: {
        type: DataTypes.STRING(150),
        defaultValue: '',
    },
}, {
    tableName: 'orders',
    timestamps: true,
    underscored: true,
});

module.exports = Order;
