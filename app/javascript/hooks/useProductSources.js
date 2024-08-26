import { useQuery, useMutation, useQueryClient } from "react-query";
import { productApi } from "@/services/api";

export const useProductSources = (productId, enabled) => {
  const queryClient = useQueryClient();

  const sourcesQuery = useQuery(
    ['productSources', productId],
    () => productApi.fetchProductSources(productId),
    { enabled }
  );

  const approveMutation = useMutation(
    productApi.approveProductSource,
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['productSources', productId]);
        queryClient.invalidateQueries("products");
      },
    }
  );

  const disapproveMutation = useMutation(
    productApi.disapproveProductSource,
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['productSources', productId]);
        queryClient.invalidateQueries("products");
      },
    }
  );

  return {
    sourcesQuery,
    approveMutation,
    disapproveMutation,
  };
};