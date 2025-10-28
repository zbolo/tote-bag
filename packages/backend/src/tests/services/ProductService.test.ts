import { ProductService } from '../../services/ProductService';
import { orm } from '../setup';
import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('ProductService', () => {
  let productService: ProductService;

  beforeEach(() => {
    const em = orm.em.fork();
    productService = new ProductService(em);
    jest.clearAllMocks();
  });

  describe('getProductByBarcode', () => {
    it('should fetch product from OpenFoodFacts API', async () => {
      const mockApiResponse = {
        data: {
          code: '12345',
          product: {
            product_name: 'Test Product',
            brands: 'Test Brand',
            generic_name: 'Generic Name',
            image_url: 'https://example.com/image.jpg',
            categories: 'Category1, Category2',
            quantity: '500g',
            nutriments: { energy: 100 },
          },
        },
      };

      mockedAxios.get.mockResolvedValue(mockApiResponse);

      const product = await productService.getProductByBarcode('12345');

      expect(product).toBeDefined();
      expect(product?.name).toBe('Test Product');
      expect(product?.brand).toBe('Test Brand');
      expect(product?.barcode).toBe('12345');
      expect(mockedAxios.get).toHaveBeenCalledWith(
        expect.stringContaining('12345'),
        expect.any(Object)
      );
    });

    it('should return cached product if recently fetched', async () => {
      const mockApiResponse = {
        data: {
          code: '12345',
          product: {
            product_name: 'Test Product',
            brands: 'Test Brand',
          },
        },
      };

      mockedAxios.get.mockResolvedValue(mockApiResponse);

      // First call - should hit API
      await productService.getProductByBarcode('12345');

      // Clear mock
      mockedAxios.get.mockClear();

      // Second call - should use cache
      const product = await productService.getProductByBarcode('12345');

      expect(product).toBeDefined();
      expect(mockedAxios.get).not.toHaveBeenCalled();
    });

    it('should return null if product not found', async () => {
      mockedAxios.get.mockResolvedValue({ data: {} });

      const product = await productService.getProductByBarcode('99999');

      expect(product).toBeNull();
    });

    it('should handle API errors gracefully', async () => {
      mockedAxios.get.mockRejectedValue(new Error('API Error'));

      const product = await productService.getProductByBarcode('12345');

      expect(product).toBeNull();
    });
  });

  describe('searchProducts', () => {
    it('should search products from OpenFoodFacts API', async () => {
      const mockApiResponse = {
        data: {
          products: [
            {
              code: '111',
              product_name: 'Product 1',
              brands: 'Brand 1',
            },
            {
              code: '222',
              product_name: 'Product 2',
              brands: 'Brand 2',
            },
          ],
        },
      };

      mockedAxios.get.mockResolvedValue(mockApiResponse);

      const products = await productService.searchProducts('milk');

      expect(products).toHaveLength(2);
      expect(products[0].name).toBe('Product 1');
      expect(products[1].name).toBe('Product 2');
    });

    it('should return empty array on API error', async () => {
      mockedAxios.get.mockRejectedValue(new Error('API Error'));

      const products = await productService.searchProducts('milk');

      expect(products).toEqual([]);
    });
  });
});
