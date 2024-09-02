import axios from "axios";
import { toast } from "@/components/ui/use-toast";

const getCsrfToken = () => document.querySelector('meta[name="csrf-token"]').getAttribute('content');

const handleApiError = async (error) => {
  let errorMessage = "An error occurred";
  let errorDetails = "";

  if (error.response) {
    errorMessage = error.response.statusText;
    try {
      errorDetails = error.response.data;
    } catch (e) {
      errorDetails = "Could not fetch error details";
    }
  } else if (error.request) {
    errorMessage = "No response received from server";
  } else {
    errorMessage = error.message;
  }

  toast({
    title: "Error",
    description: (
      <div>
        {errorMessage}
        <button onClick={() => alert(JSON.stringify(errorDetails))} className="ml-2 underline">
          View Details
        </button>
      </div>
    ),
    variant: "destructive",
  });

  throw error; // Re-throw the error so it can be caught by React Query
};

const api = axios.create({
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-CSRF-Token': getCsrfToken(),
  },
});

// Add a response interceptor
api.interceptors.response.use(
  response => response,
  error => handleApiError(error)
);

// example product API
export const productApi = {
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

export default api;