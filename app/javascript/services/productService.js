// Example product service
import { api } from './api';

export const productService = {
  fetchProducts: async (offset = 0) => {
    const { data } = await api.get(`/api/v1/products?offset=${offset}`);
    return data;
  },
  deleteProduct: (id) => api.delete(`/api/v1/products/${id}`),
  restoreProduct: (id) => api.post(`/api/v1/products/${id}/restore`),
  validateProduct: (id) => api.post(`/api/v1/products/${id}/validate`),
  fetchProductSources: async (productId) => {
    const { data } = await api.get(`/api/v1/products/${productId}/sources`);
    return data;
  },
  approveProductSource: async ({ sourceId, productId, replaceOptions }) => {
    const { data } = await api.post(`/api/v1/product_sources/${sourceId}/approve`, {
      ...replaceOptions,
      product_id: productId
    });
    return data;
  },
  disapproveProductSource: async ({ sourceId, productId }) => {
    const { data } = await api.post(`/api/v1/product_sources/${sourceId}/disapprove`, {
      product_id: productId
    });
    return data;
  },
};