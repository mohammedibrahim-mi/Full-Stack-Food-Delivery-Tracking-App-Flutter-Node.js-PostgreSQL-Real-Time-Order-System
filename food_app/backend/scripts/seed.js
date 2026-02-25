const bcrypt = require('bcryptjs');
const { sequelize, User, Category, Restaurant, MenuItem } = require('../models');

async function seed() {
    try {
        console.log('🔄 Syncing database (force: true — drops existing tables)...');
        await sequelize.sync({ force: true });
        console.log('✅ Tables created.\n');

        // ─── Demo User ───────────────────────────────────────────────
        const hash = await bcrypt.hash('password123', 10);
        await User.create({
            name: 'John Doe',
            email: 'john@gmail.com',
            password_hash: hash,
            phone: '+1 555-0123',
            address: '123 Foodie Street, Flavor Town',
            avatar_url: '',
        });
        console.log('👤 Demo user created (john@gmail.com / password123)');

        // ─── Categories ──────────────────────────────────────────────
        const categories = await Category.bulkCreate([
            { name: 'Pizza', icon: '🍕', color: '#FF6B35' },
            { name: 'Burger', icon: '🍔', color: '#FFD23F' },
            { name: 'Sushi', icon: '🍣', color: '#00E676' },
            { name: 'Chinese', icon: '🥡', color: '#FF5252' },
            { name: 'Desserts', icon: '🍰', color: '#E040FB' },
            { name: 'Indian', icon: '🍛', color: '#FF9800' },
            { name: 'Mexican', icon: '🌮', color: '#8BC34A' },
            { name: 'Healthy', icon: '🥗', color: '#26C6DA' },
        ]);
        console.log(`🗂  ${categories.length} categories seeded`);

        // ─── Restaurants (Madurai, India Demo Locations) ──────────────
        const restaurants = await Restaurant.bulkCreate([
            {
                name: 'Murugan Idli Shop',
                image_url: 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=600&fit=crop',
                cuisine: 'South Indian • Tiffin',
                rating: 4.8,
                delivery_time: '15-25 min',
                delivery_fee: 29,
                min_order: 99,
                is_featured: true,
                address: 'West Masi Street, Madurai',
                latitude: 9.9190,
                longitude: 78.1190,
                category_id: 1,
            },
            {
                name: 'Amma Mess',
                image_url: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&fit=crop',
                cuisine: 'Tamil Nadu • Non-Veg',
                rating: 4.9,
                delivery_time: '25-35 min',
                delivery_fee: 39,
                min_order: 199,
                is_featured: true,
                address: 'Alwarpuram, Madurai',
                latitude: 9.9280,
                longitude: 78.1105,
                category_id: 2,
            },
            {
                name: 'Kumar Mess',
                image_url: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&fit=crop',
                cuisine: 'Chettinad • Meals',
                rating: 4.7,
                delivery_time: '25-35 min',
                delivery_fee: 39,
                min_order: 199,
                is_featured: true,
                address: 'Simmakkal, Madurai',
                latitude: 9.9230,
                longitude: 78.1180,
                category_id: 3,
            },
            {
                name: 'Anjappar Chettinad Restaurant',
                image_url: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&fit=crop',
                cuisine: 'Chettinad • Biryani',
                rating: 4.6,
                delivery_time: '30-40 min',
                delivery_fee: 49,
                min_order: 249,
                is_featured: true,
                address: 'Bypass Road, Madurai',
                latitude: 9.9400,
                longitude: 78.1300,
                category_id: 4,
            },
            {
                name: 'A2B Adyar Ananda Bhavan',
                image_url: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&fit=crop',
                cuisine: 'Veg • Sweets & Snacks',
                rating: 4.7,
                delivery_time: '20-30 min',
                delivery_fee: 29,
                min_order: 149,
                is_featured: true,
                address: 'Anna Nagar, Madurai',
                latitude: 9.9355,
                longitude: 78.1255,
                category_id: 5,
            },
            {
                name: 'Sree Sabarees',
                image_url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&fit=crop',
                cuisine: 'South Indian • Veg Meals',
                rating: 4.5,
                delivery_time: '20-30 min',
                delivery_fee: 29,
                min_order: 129,
                is_featured: false,
                address: 'KK Nagar, Madurai',
                latitude: 9.9315,
                longitude: 78.0975,
                category_id: 6,
            },
            {
                name: 'Madurai Famous Jigarthanda',
                image_url: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&fit=crop',
                cuisine: 'Beverages • Dessert',
                rating: 4.9,
                delivery_time: '15-20 min',
                delivery_fee: 19,
                min_order: 79,
                is_featured: true,
                address: 'East Masi Street, Madurai',
                latitude: 9.9180,
                longitude: 78.1210,
                category_id: 7,
            },
            {
                name: 'Dindigul Thalappakatti',
                image_url: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=600&fit=crop',
                cuisine: 'Biryani • Tamil Nadu',
                rating: 4.8,
                delivery_time: '30-40 min',
                delivery_fee: 49,
                min_order: 249,
                is_featured: true,
                address: 'Mattuthavani, Madurai',
                latitude: 9.9420,
                longitude: 78.1370,
                category_id: 8,
            }
        ]);
        console.log(`🍽  ${restaurants.length} restaurants seeded (Madurai locations)`);

        // ─── Menu Items ──────────────────────────────────────────────
        const menuItems = await MenuItem.bulkCreate([

            // ── Murugan Idli Shop (restaurant_id: 1) ──────────────────
            {
                name: 'Idli (2 pcs)',
                description: 'Soft steamed idlis served with chutney & sambar',
                price: 40,
                image_url: 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 1,
            },
            {
                name: 'Ghee Podi Idli',
                description: 'Mini idlis tossed in ghee and podi masala',
                price: 70,
                image_url: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 1,
            },
            {
                name: 'Masala Dosa',
                description: 'Crispy dosa filled with spiced potato masala',
                price: 90,
                image_url: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 1,
            },
            {
                name: 'Filter Coffee',
                description: 'Authentic South Indian filter coffee in traditional tumbler',
                price: 30,
                image_url: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 1,
            },

            // ── Amma Mess (restaurant_id: 2) ──────────────────────────
            {
                name: 'Chicken Curry Meals',
                description: 'Traditional Madurai chicken curry meals with unlimited rice',
                price: 220,
                image_url: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 2,
            },
            {
                name: 'Mutton Chukka',
                description: 'Spicy Madurai style dry mutton fry with fresh spices',
                price: 260,
                image_url: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 2,
            },
            {
                name: 'Kari Dosa',
                description: 'Crispy dosa topped with minced mutton masala',
                price: 180,
                image_url: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 2,
            },

            // ── Kumar Mess (restaurant_id: 3) ─────────────────────────
            {
                name: 'Non-Veg Meals',
                description: 'Unlimited meals with chicken & mutton gravies, rice, rasam',
                price: 250,
                image_url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 3,
            },
            {
                name: 'Chicken Chettinad',
                description: 'Authentic Chettinad chicken masala with kalpasi & marathi mokku',
                price: 230,
                image_url: 'https://images.unsplash.com/photo-1603893662172-99ed0cea2a08?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 3,
            },
            {
                name: 'Fish Fry',
                description: 'Masala marinated crispy fried fish — Madurai street style',
                price: 200,
                image_url: 'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 3,
            },

            // ── Anjappar Chettinad (restaurant_id: 4) ─────────────────
            {
                name: 'Chicken Chettinad',
                description: 'Signature Chettinad chicken curry — bold & aromatic',
                price: 240,
                image_url: 'https://images.unsplash.com/photo-1603893662172-99ed0cea2a08?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 4,
            },
            {
                name: 'Mutton Biryani',
                description: 'Traditional Chettinad dum biryani with tender mutton',
                price: 280,
                image_url: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 4,
            },
            {
                name: 'Pepper Chicken',
                description: 'Dry pepper roasted chicken — smoky and spicy',
                price: 260,
                image_url: 'https://images.unsplash.com/photo-1598515213692-5f252f75d785?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 4,
            },

            // ── A2B Adyar Ananda Bhavan (restaurant_id: 5) ────────────
            {
                name: 'Mini Tiffin',
                description: 'Idli, dosa, pongal and vada combo with 3 chutneys',
                price: 150,
                image_url: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 5,
            },
            {
                name: 'Ghee Pongal',
                description: 'Creamy rice and lentil dish cooked with ghee, ginger & pepper',
                price: 120,
                image_url: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 5,
            },
            {
                name: 'Mysore Pak',
                description: 'Classic South Indian ghee-based sweet — melt in mouth',
                price: 90,
                image_url: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 5,
            },

            // ── Sree Sabarees (restaurant_id: 6) ──────────────────────
            {
                name: 'South Indian Meals',
                description: 'Full veg meals with sambar, rasam, kootu, rice & papad',
                price: 130,
                image_url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 6,
            },
            {
                name: 'Rava Dosa',
                description: 'Thin crispy semolina dosa with ginger and green chilli',
                price: 90,
                image_url: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 6,
            },
            {
                name: 'Curd Rice',
                description: 'Cooling curd rice tempered with mustard, curry leaves & pomegranate',
                price: 80,
                image_url: 'https://images.unsplash.com/photo-1512058564366-c9e3e046e7b1?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 6,
            },

            // ── Jigarthanda Shop (restaurant_id: 7) ───────────────────
            {
                name: 'Special Jigarthanda',
                description: 'Madurai famous cooling drink — nannari syrup, badam pisin, milk & ice cream',
                price: 80,
                image_url: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 7,
            },
            {
                name: 'Rose Milk',
                description: 'Chilled rose-flavored fresh milk — refreshing & sweet',
                price: 50,
                image_url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 7,
            },
            {
                name: 'Falooda',
                description: 'Layered ice cream falooda with basil seeds and rose syrup',
                price: 120,
                image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 7,
            },

            // ── Dindigul Thalappakatti (restaurant_id: 8) ─────────────
            {
                name: 'Mutton Thalappakatti Biryani',
                description: 'Dindigul style seeraga samba biryani with tender mutton — the original',
                price: 300,
                image_url: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 8,
            },
            {
                name: 'Chicken Biryani',
                description: 'Signature Thalappakatti chicken biryani — fragrant & spicy',
                price: 260,
                image_url: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&fit=crop',
                is_popular: true,
                restaurant_id: 8,
            },
            {
                name: 'Chicken 65',
                description: 'Spicy deep fried chicken starter — crispy outside, juicy inside',
                price: 180,
                image_url: 'https://images.unsplash.com/photo-1598515213692-5f252f75d785?w=400&fit=crop',
                is_popular: false,
                restaurant_id: 8,
            },
        ]);
        console.log(`🍱 ${menuItems.length} menu items seeded`);

        console.log('\n🎉 Database seeded successfully!');
        process.exit(0);
    } catch (err) {
        console.error('❌ Seed failed:', err);
        process.exit(1);
    }
}

seed();
