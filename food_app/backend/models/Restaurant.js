const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Restaurant = sequelize.define('Restaurant', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING(150),
        allowNull: false,
    },
    image_url: {
        type: DataTypes.STRING(500),
        defaultValue: '',
    },
    cuisine: {
        type: DataTypes.STRING(100),
        defaultValue: '',
    },
    rating: {
        type: DataTypes.FLOAT,
        defaultValue: 4.0,
        validate: { min: 0, max: 5 },
    },
    delivery_time: {
        type: DataTypes.STRING(30),
        defaultValue: '30-45 min',
    },
    delivery_fee: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
    },
    min_order: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
    },
    is_featured: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    address: {
        type: DataTypes.TEXT,
        defaultValue: '',
    },
    latitude: {
        type: DataTypes.DOUBLE,
        defaultValue: 0,
    },
    longitude: {
        type: DataTypes.DOUBLE,
        defaultValue: 0,
    },
    category_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
}, {
    tableName: 'restaurants',
    timestamps: true,
    underscored: true,
});

module.exports = Restaurant;
