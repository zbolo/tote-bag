import axios from 'axios';
import { Product } from '../entities/Product.js';

/**
 * Product Service
 * Handles product lookup and caching from OpenFoodFacts API
 */
export class ProductService {
  /**
   * @param {import('@mikro-orm/core').EntityManager} em - MikroORM Entity Manager
   */
  constructor(em) {
    this.em = em;
    this.apiUrl = process.env.OPENFOODFACTS_API_URL || 'https://world.openfoodfacts.org/api/v2';
  }

  /**
   * Get product by barcode
   * @param {string} barcode - Product barcode
   * @returns {Promise<Product | null>}
   */
  async getProductByBarcode(barcode) {
    console.log(`[ProductService] Looking up barcode: ${barcode}`);

    // Check if product exists in database and is recent
    const existingProduct = await this.em.findOne(Product, { barcode });

    if (existingProduct) {
      const hoursSinceLastFetch = existingProduct.lastFetchedAt
        ? (Date.now() - existingProduct.lastFetchedAt.getTime()) / (1000 * 60 * 60)
        : Infinity;

      // Return cached product if fetched within last 24 hours
      if (hoursSinceLastFetch < 24) {
        console.log(`[ProductService] Returning cached product: ${existingProduct.name}`);
        return existingProduct;
      }
    }

    // Fetch from OpenFoodFacts API
    try {
      console.log(`[ProductService] Fetching from OpenFoodFacts API...`);
      const response = await axios.get(
        `${this.apiUrl}/product/${barcode}.json`,
        {
          timeout: 5000,
          headers: {
            'User-Agent': 'ToteBag/1.0',
          },
        }
      );

      if (response.data && response.data.product) {
        const apiProduct = response.data.product;

        const productData = {
          barcode,
          name: apiProduct.product_name || apiProduct.generic_name || 'Unknown Product',
          brand: apiProduct.brands,
          description: apiProduct.generic_name,
          imageUrl: apiProduct.image_url,
          category: apiProduct.categories?.split(',')[0]?.trim(),
          quantity: apiProduct.quantity,
          nutritionData: apiProduct.nutriments,
          source: 'openfoodfacts',
          lastFetchedAt: new Date(),
        };

        if (existingProduct) {
          console.log(`[ProductService] Updating cached product: ${productData.name}`);
          this.em.assign(existingProduct, productData);
          await this.em.flush();
          return existingProduct;
        } else {
          console.log(`[ProductService] Creating new product: ${productData.name}`);
          const newProduct = this.em.create(Product, productData);
          await this.em.persistAndFlush(newProduct);
          return newProduct;
        }
      }
    } catch (error) {
      console.error('[ProductService] Error fetching product from OpenFoodFacts:', error.message);
      // Return cached product if available, even if outdated
      if (existingProduct) {
        console.log(`[ProductService] Returning outdated cached product due to API error`);
        return existingProduct;
      }
    }

    console.log(`[ProductService] Product not found: ${barcode}`);
    return null;
  }

  /**
   * Search products by query
   * @param {string} query - Search query
   * @param {number} [limit=20] - Maximum number of results
   * @returns {Promise<Product[]>}
   */
  async searchProducts(query, limit = 20) {
    console.log(`[ProductService] Searching products: "${query}" (limit: ${limit})`);

    try {
      const response = await axios.get(
        `${this.apiUrl}/search`,
        {
          params: {
            search_terms: query,
            page_size: limit,
            json: true,
          },
          timeout: 5000,
          headers: {
            'User-Agent': 'ToteBag/1.0',
          },
        }
      );

      const products = [];

      if (response.data && response.data.products) {
        console.log(`[ProductService] Found ${response.data.products.length} products`);

        for (const apiProduct of response.data.products) {
          if (!apiProduct.code) continue;

          let product = await this.em.findOne(Product, { barcode: apiProduct.code });

          if (!product) {
            product = this.em.create(Product, {
              barcode: apiProduct.code,
              name: apiProduct.product_name || apiProduct.generic_name || 'Unknown Product',
              brand: apiProduct.brands,
              description: apiProduct.generic_name,
              imageUrl: apiProduct.image_url,
              category: apiProduct.categories?.split(',')[0]?.trim(),
              quantity: apiProduct.quantity,
              nutritionData: apiProduct.nutriments,
              source: 'openfoodfacts',
              lastFetchedAt: new Date(),
            });
            this.em.persist(product);
          }

          products.push(product);
        }

        await this.em.flush();
      }

      console.log(`[ProductService] Returning ${products.length} products`);
      return products;
    } catch (error) {
      console.error('[ProductService] Error searching products:', error.message);
      return [];
    }
  }
}
