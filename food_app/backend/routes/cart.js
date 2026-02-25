const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/cartController');
const auth = require('../middleware/auth');

router.use(auth); // All cart routes require auth

router.get('/', ctrl.getCart);
router.post('/', ctrl.addItem);
router.put('/:id', ctrl.updateItem);
router.delete('/clear', ctrl.clearCart);
router.delete('/:id', ctrl.removeItem);

module.exports = router;
