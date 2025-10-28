import axios from 'axios';
import { EntityManager } from '@mikro-orm/core';
import { Product } from '../entities/Product';

interface OpenFoodFactsProduct {
  code: string;
  product: {
    product_name?: string;
    brands?: string;
    generic_name?: string;
    image_url?: string;
    categories?: string;
    quantity?: string;
    nutriments?: Record<string, any>;
  };
}

export class ProductService {
  private readonly apiUrl: string;

  constructor(private em: EntityManager) {
    this.apiUrl = process.env.OPENFOODFACTS_API_URL || 'https://world.openfoodfacts.org/api/v2';
  }

  async getProductByBarcode(barcode: string): Promise<Product | null> {
    // Check if product exists in database and is recent
    const existingProduct = await this.em.findOne(Product, { barcode });

    if (existingProduct) {
      const hoursSinceLastFetch = existingProduct.lastFetchedAt
        ? (Date.now() - existingProduct.lastFetchedAt.getTime()) / (1000 * 60 * 60)
        : Infinity;

      // Return cached product if fetched within last 24 hours
      if (hoursSinceLastFetch < 24) {
        return existingProduct;
      }
    }

    // Fetch from OpenFoodFacts API
    try {
      const response = await axios.get<OpenFoodFactsProduct>(
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
          this.em.assign(existingProduct, productData);
          await this.em.flush();
          return existingProduct;
        } else {
          const newProduct = this.em.create(Product, productData);
          await this.em.persistAndFlush(newProduct);
          return newProduct;
        }
      }
    } catch (error) {
      console.error('Error fetching product from OpenFoodFacts:', error);
      // Return cached product if available, even if outdated
      if (existingProduct) {
        return existingProduct;
      }
    }

    return null;
  }

  async searchProducts(query: string, limit: number = 20): Promise<Product[]> {
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
        }
      );

      const products: Product[] = [];

      if (response.data && response.data.products) {
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

      return products;
    } catch (error) {
      console.error('Error searching products:', error);
      return [];
    }
  }
}
