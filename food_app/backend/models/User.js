const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING(150),
        allowNull: false,
        unique: true,
        validate: { isEmail: true },
    },
    password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    phone: {
        type: DataTypes.STRING(20),
        defaultValue: '',
    },
    address: {
        type: DataTypes.TEXT,
        defaultValue: '',
    },
    avatar_url: {
        type: DataTypes.STRING(500),
        defaultValue: '',
    },
}, {
    tableName: 'users',
    timestamps: true,
    underscored: true,
});

module.exports = User;
