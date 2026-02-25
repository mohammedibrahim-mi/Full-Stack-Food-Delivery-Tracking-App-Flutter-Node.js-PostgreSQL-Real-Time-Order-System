const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const MenuItem = sequelize.define('MenuItem', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING(150),
        allowNull: false,
    },
    description: {
        type: DataTypes.TEXT,
        defaultValue: '',
    },
    price: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    image_url: {
        type: DataTypes.STRING(500),
        defaultValue: '',
    },
    is_popular: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    restaurant_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
}, {
    tableName: 'menu_items',
    timestamps: false,
});

module.exports = MenuItem;
