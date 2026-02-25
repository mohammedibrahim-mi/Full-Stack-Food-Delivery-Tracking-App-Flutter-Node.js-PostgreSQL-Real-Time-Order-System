const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/ordersController');
const auth = require('../middleware/auth');

router.use(auth); // All order routes require auth

router.get('/', ctrl.getOrders);
router.get('/:id', ctrl.getOrderById);
router.post('/', ctrl.placeOrder);

module.exports = router;
