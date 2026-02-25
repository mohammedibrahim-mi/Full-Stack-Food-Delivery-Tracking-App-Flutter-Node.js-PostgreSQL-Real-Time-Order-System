const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Category = sequelize.define('Category', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    icon: {
        type: DataTypes.STRING(10),
        allowNull: false,
    },
    color: {
        type: DataTypes.STRING(10),
        defaultValue: '#FF6B35',
    },
}, {
    tableName: 'categories',
    timestamps: false,
});

module.exports = Category;
