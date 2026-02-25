const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/menuController');

router.get('/:restaurantId', ctrl.getByRestaurant);
router.get('/item/:id', ctrl.getById);

module.exports = router;
